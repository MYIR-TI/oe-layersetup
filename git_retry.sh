#!/bin/sh

glMaxRetries=5
glCurrRetry=1
glDelay=15
glExitCode=0

while [ $glMaxRetries -ge $glCurrRetry ]; do

    git "$@"

    glExitCode=$?

    if [ $glExitCode -eq 0 ]; then
        exit
    fi

    glSleep=$((glDelay*glCurrRetry))

    glRemainingRetries=$((glMaxRetries-glCurrRetry))

    if [ $glRemainingRetries -gt 0 ]; then
        echo "git failed... remaining attempts: $glRemainingRetries    sleeping $glSleep seconds"
        sleep $glSleep
    fi

    glCurrRetry=$((glCurrRetry+1))

done

echo "git failed... giving up..."

exit $glExitCode

