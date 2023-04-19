#!/bin/bash

let glMaxRetries=5
let glCurrRetry=1
let glDelay=15
let glExitCode=0

while [ $glMaxRetries -ge $glCurrRetry ]; do

    git "$@"

    glExitCode=$?

    if [ $glExitCode -eq 0 ]; then
        exit
    fi

    let glSleep=$glDelay*$glCurrRetry

    let glRemainingRetries=$glMaxRetries-$glCurrRetry

    if [ $glRemainingRetries -gt 0 ]; then
        echo "git failed... remaining attempts: $glRemainingRetries    sleeping $glSleep seconds"
        sleep $glSleep
    fi

    let glCurrRetry=$glCurrRetry+1

done

echo "git failed... giving up..."

exit $glExitCode

