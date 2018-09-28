#!/bin/bash

rm -rdf mdapiRefresh/
sfdx force:mdapi:retrieve -s -k ../mdapi/package.xml -r ../mdapiRefresh
sfdx dbs:zip:uncompress -s ../mdapiRefresh/unpackaged.zip -t ../mdapiRefresh/ -r
sfdx force:mdapi:convert -r ../mdapiRefresh

