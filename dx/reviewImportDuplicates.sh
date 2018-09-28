#!/bin/bash

find . -type f -iname "*.dup" -print0 | while IFS= read -r -d $'\0' line; do
    echo "duplicate found: $line"
    dup="${line}"
    nonDup=$(echo "${line}" | rev | cut -d '.' -f2- | rev)
    
    #create the original
    orig="${nonDup}.orig"
    cp "${nonDup}" "${orig}"
    
    #echo "${line}"
    #echo "${nonDup}"
    #echo "${orig}"
    
    #read -n1 -r -p "Press space to continue..." key
    #unset key

    diffmerge -i "${orig}" "${nonDup}" "${dup}" -t1="orig" -t2="current" -t3="duplicate"
done