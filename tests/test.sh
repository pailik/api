#!/usr/bin/env bash

printf '%.0s-' {1..80}
echo

URL=$1

COUNT_TESTS=0
COUNT_TESTS_FAIL=0

assertTrue() {
    testName="$3"
    pad=$(printf '%0.1s' "."{1..80})
    padlength=78

    if [ "$1" != "$2" ]; then
        printf ' %s%*.*s%s' "$3" 0 $((padlength - ${#testName} - 4)) "$pad" "Fail"
        printf ' (assertion %s, expected %s)\n' "$1" "$2"
        let "COUNT_TESTS_FAIL++"
    else
        printf ' %s%*.*s%s\n' "$3" 0 $((padlength - ${#testName} - 2)) "$pad" "Ok"
        let "COUNT_TESTS++"
    fi
}

testAuth() {
    ACTUAL=$(curl --write-out %{http_code} --silent --output /dev/null http://$URL/auth?code=222)

    assertTrue 200 $ACTUAL "$FUNCNAME Code"

    EXPECTED='{"links":{"task":"http:\/\/kubikvest.xyz\/task?t=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJhdXRoX3Byb3ZpZGVyIjoidmsiLCJ1c2VyX2lkIjo2Njc0OCwidHRsIjo0MzIwMCwia3Zlc3RfaWQiOjEsInBvaW50X2lkIjowfQ.V0d2cNMNMretk_QMR5oa7fYHorrV2MhHTBwA8DsJffw"}}'

    ACTUAL=$(curl --silent http://$URL/auth?code=222)

    assertTrue "$EXPECTED" "$ACTUAL" "$FUNCNAME body"
}

testTask() {
    ACTUAL=$(curl --write-out %{http_code} --silent --output /dev/null "http://$URL/task?t=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJhdXRoX3Byb3ZpZGVyIjoidmsiLCJ1c2VyX2lkIjo2Njc0OCwidHRsIjo0MzIwMCwia3Zlc3RfaWQiOjEsInBvaW50X2lkIjowfQ.V0d2cNMNMretk_QMR5oa7fYHorrV2MhHTBwA8DsJffw")

    assertTrue 200 $ACTUAL "$FUNCNAME Code"

    BODY=$(curl --silent "http://$URL/task?t=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJhdXRoX3Byb3ZpZGVyIjoidmsiLCJ1c2VyX2lkIjo2Njc0OCwidHRsIjo0MzIwMCwia3Zlc3RfaWQiOjEsInBvaW50X2lkIjowfQ.V0d2cNMNMretk_QMR5oa7fYHorrV2MhHTBwA8DsJffw")

    DESCRIPTION=$(echo $BODY | jq '.description' | sed -e 's/^"//' -e 's/"$//')
    assertTrue "Вы должны прийти сюда чтобы начать" "$DESCRIPTION" "$FUNCNAME DESCRIPTION"

    POINT_ID=$(echo $BODY | jq '.point_id' | sed -e 's/^"//' -e 's/"$//')
    assertTrue "0" "$POINT_ID" "$FUNCNAME POINT_ID"

    TOTAL_POINTS=$(echo $BODY | jq '.total_points' | sed -e 's/^"//' -e 's/"$//')
    assertTrue "4" "$TOTAL_POINTS" "$FUNCNAME TOTAL_POINTS"

    CHECKPOINT=$(echo $BODY | jq '.links.checkpoint' | sed -e 's/^"//' -e 's/"$//')
    assertTrue "http://kubikvest.xyz/checkpoint?t=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJhdXRoX3Byb3ZpZGVyIjoidmsiLCJ1c2VyX2lkIjo2Njc0OCwidHRsIjo0MzIwMCwia3Zlc3RfaWQiOjEsInBvaW50X2lkIjowfQ.V0d2cNMNMretk_QMR5oa7fYHorrV2MhHTBwA8DsJffw" "$CHECKPOINT" "$FUNCNAME CHECKPOINT"
}

testAuth
testTask

printf '%.0s-' {1..80}
echo
printf 'Total test: %s, fail: %s\n\n' "$COUNT_TESTS" "$COUNT_TESTS_FAIL"

if [ $COUNT_TESTS_FAIL -gt 0 ]; then
    exit 1
fi

exit 0
