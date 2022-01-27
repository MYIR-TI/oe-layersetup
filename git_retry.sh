#!/bin/bash

let glRetries=5
let glDelay=15
let glExitCode=0

while [ $glRetries -gt 0 ]; do

    git "$@"

    glExitCode=$?

    if [ $glExitCode -eq 0 ]; then
        exit
    fi

    let glRetries=$glRetries-1

    if [ $glRetries -gt 0 ]; then
        echo "git failed... remaining attempts: $glRetries"
        sleep $glDelay
    fi

done

echo "git failed... giving up..."

exit $glExitCode

