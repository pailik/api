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

    EXPECTED='{"description":"\u0412\u044b \u0434\u043e\u043b\u0436\u043d\u044b \u043f\u0440\u0438\u0439\u0442\u0438 \u0441\u044e\u0434\u0430 \u0447\u0442\u043e\u0431\u044b \u043d\u0430\u0447\u0430\u0442\u044c","point_id":0,"total_points":4,"links":{"checkpoint":"http:\/\/kubikvest.xyz\/checkpoint?t=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJhdXRoX3Byb3ZpZGVyIjoidmsiLCJ1c2VyX2lkIjo2Njc0OCwidHRsIjo0MzIwMCwia3Zlc3RfaWQiOjEsInBvaW50X2lkIjowfQ.V0d2cNMNMretk_QMR5oa7fYHorrV2MhHTBwA8DsJffw"}}'
    ACTUAL=$(curl --silent "http://$URL/task?t=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJhdXRoX3Byb3ZpZGVyIjoidmsiLCJ1c2VyX2lkIjo2Njc0OCwidHRsIjo0MzIwMCwia3Zlc3RfaWQiOjEsInBvaW50X2lkIjowfQ.V0d2cNMNMretk_QMR5oa7fYHorrV2MhHTBwA8DsJffw")

    assertTrue "$EXPECTED" "$ACTUAL" "$FUNCNAME body"
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
