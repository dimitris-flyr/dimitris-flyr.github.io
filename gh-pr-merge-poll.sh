#!/bin/bash

# Prerequisites
# 1. brew install gh
# 2. Login with gh account

prid=$1
sleep_in_s=20

while true
do
    echo "Trying to merge"
    gh pr merge $prid --squash --repo https://github.com/FlyrInc/fusionrm
    if [ $? -eq 0 ]; then
        exit 0
    else
        echo "X Pull request #$prid is not mergeable. Retrying again in $sleep_in_s seconds..."
    fi
    sleep $sleep_in_s
done
