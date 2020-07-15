#!/bin/bash
gid=200
goinstall=oinstall
gdba=dba
uoracle=oracle

grep $uoracle /etc/passwd > /dev/null 2>&1
if [[ $? -eq 0 ]];then
	echo "delete user $uoracle"
	userdel -r $uoracle
fi

sleep 1s

function create_group()
{
	echo "initial gid $gid"
	while [[ $gid -lt 1000 ]]
	do
		grep $gid /etc/group > /dev/null  2>&1
		if [[ $? -ne 0 ]];then
			echo "create group $1, group id is $gid"
			groupadd -g $gid $1
			((gid++))
			break;
		else
			((gid++))
		fi
	done
}

function delete_group()
{
	grep $1 /etc/group > /dev/null 2>&1
	if [[ $? -eq 0 ]];then
		echo "delete group $1"
		groupdel $1
	fi
}

delete_group $goinstall
delete_group $gdba

create_group $goinstall
create_group $gdba

useradd -g $goinstall -G $gdba $uoracle
echo "$uoracle" | passwd --stdin $uoracle
if [[ $? -eq 0 ]];then
	gpasswd -a $uoracle root
fi

echo "final gid $gid"
