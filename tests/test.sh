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

testAuth

printf '%.0s-' {1..80}
echo
printf 'Total test: %s, fail: %s\n\n' "$COUNT_TESTS" "$COUNT_TESTS_FAIL"

if [ $COUNT_TESTS_FAIL -gt 0 ]; then
    exit 1
fi

exit 0
