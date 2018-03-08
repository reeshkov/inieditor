#!/bin/bash
set -e
#echo "test get key"
#./iniedit.sh test.ini -G testkey
#echo "test get section"
#./iniedit.sh test.ini -v -G [testgroup]
#echo "test get key from section"
#./iniedit.sh test.ini -G [testgroup] testkeyingroup

#echo "test set key"
#./iniedit.sh test.ini -S testkey testsetvalue
#./iniedit.sh test.ini -S notexistkey testsetvalue

#echo "test set section"
#./iniedit.sh test.ini -S [testgroup]
#./iniedit.sh test.ini -S [setnexistgroup]

#echo "test set key in section"
#./iniedit.sh test.ini -v -S [testgroup] testkeyingroup settestvalue
#./iniedit.sh test.ini -v -S [testgroup] newkey newvalue
./iniedit.sh test.ini -v -w -S [notexistsec] settestkeyingroup testvalue

#echo "test del"
#./iniedit.sh test.ini -v -D testkey
#./iniedit.sh test.ini -v -D [testgroup]
#./iniedit.sh test.ini -v -D [testgroup] testkeyingroup
