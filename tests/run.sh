#!/bin/bash

export SHUNIT_PATH=/usr/bin/shunit2
export SHUNIT_COLOR=always

for test in $(ls -1 test_*)
do
	echo "------------- $test -------------"
	./$test
	echo
done
