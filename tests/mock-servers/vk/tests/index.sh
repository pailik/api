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

testAccessToken() {
    ACTUAL=$(curl --write-out %{http_code} --silent --output /dev/null "http://$URL/access_token?client_id=111&client_secret=secret&redirect_uri=kubikvest&code=222")

    assertTrue 200 $ACTUAL $FUNCNAME
}

testFailAccessToken() {
    ACTUAL=$(curl --write-out %{http_code} --silent --output /dev/null "http://$URL/access_token?client_id=333&client_secret=secret&redirect_uri=kubikvest&code=222")

    assertTrue 400 $ACTUAL $FUNCNAME
}

testAccessToken
testFailAccessToken

printf '%.0s-' {1..80}
echo
printf 'Total test: %s, fail: %s\n\n' "$COUNT_TESTS" "$COUNT_TESTS_FAIL"

if [ $COUNT_TESTS_FAIL -gt 0 ]; then
    exit 1
fi

exit 0
