#!/bin/bash

checker() {
	if [ $? ]
	then
		echo $?
	fi
}

vmname=''
vmcnt=0
vmsize=0

echo -e "\t\t관리자(대시보드)"
echo -en "\t인스턴스이름: "
read vmname

while [ 1 ]
do
	echo -en "\t인스턴스사이즈: "
	read vmsize
	if [ $vmsize -ge 6 ]
	then
		break
	fi
		echo "! 최소 6G 이상의 공간이 필요합니다"
done

echo -en "\t인스턴스갯수: "
read vmcnt

echo -e "\t설치를 진행합니다"
for ((i=0 ; i<$vmcnt ; i++))
do
	virt-builder centos-7.8  --format qcow2 --size ${vmsize}G \
	-o /cloud/$vmname-$i.qcow2 --root-password password:test123
	checker

	if ((i%2 == 0))
	then
		ssh kvm2 virt-install --name $vmname-$i --vcpus 1 --ram 1024 \
		--disk /cloud/$vmname-$i.qcow2 --import \
		--network bridge:vswitch01,model=virtio,virtualport_type=openvswitch,target=$vmname_0$i \
		--os-type=linux --os-variant=rhel7 --noautoconsole
	else
		virt-install --name $vmname-$i --vcpus 1 --ram 1024 \
		--disk /cloud/$vmname-$i.qcow2 --import \
		--network bridge:vswitch01,model=virtio,virtualport_type=openvswitch,target=$vmname_0$i \
		--os-type=linux --os-variant=rhel7 --noautoconsole
	fi
	checker
done