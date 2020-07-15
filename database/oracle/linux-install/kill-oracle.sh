#!/bin/bash
for i in $( ps -ef | grep oracle | awk '{print $2}' )
do
	echo kill $i
	kill $i
done
