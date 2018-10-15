#!/bin/bash

# refresh the mdapi folder - for the latest package.xml file
sfdx force:source:convert -r force-app -d ../mdapi
# retrieve the latest using the package
sfdx force:mdapi:retrieve -s -k ../mdapi/package.xml -r ../mdapiRefresh
# unzip the package so we can import it
sfdx dbs:zip:uncompress -s ../mdapiRefresh/unpackaged.zip -t ../mdapiRefresh/ -r
# import the files
sfdx force:mdapi:convert -r ../mdapiRefresh

