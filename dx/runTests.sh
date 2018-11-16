#!/bin/bash

echo 'pushing latest code though salesforce cli'
sfdx force:source:push

if [ $? -eq 0 ]; then
    echo OK
    echo 'running test:'
    sfdx force:apex:test:run -y -r human "$@"
else
    echo FAIL
fi

