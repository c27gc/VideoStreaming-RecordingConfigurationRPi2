#!/bin/bash

cleanup()
{
	rm -f /tmp/tempfile
	return $?
}

control_c()
# run if user hits control-c
{
  echo -en "\n*** Exiting ***\n"
  sudo pkill mjpg_streamer
  K=`wc -l /etc/fstab`
  if [ "$K" = "4 /etc/fstab" ];then
  	sudo sed -i".bak" '$d' /etc/fstab
  fi
  cleanup
  exit $?
}


Msda=`sudo fdisk -l /dev/sda1`
Msdb=`sudo fdisk -l /dev/sdb1`
Msdc=`sudo fdisk -l /dev/sdc1`

if [ "$Msda" != "" ]; then
	M="/dev/sda1"
elif [ "$Msdb" != "" ]; then
	M="/dev/sdb1"
else
	if [ "$Msdc" != "" ]; then
		M="/dev/sdc1"
		else
			M="NADA"
	fi
fi

C="$M"
T='\t/media/PenDrive\tvfat\tdefaults\t0\t0'

if [ "$M" != "NADA" ]; then
	echo -e $C $T >> /etc/fstab
	sudo mount -a
else
	echo "Unidentified storage device."
	exit 1
fi

mark="a"
trap control_c SIGINT
while true;  do
	if [ "$mark" = "a" ]; then
		echo "Configuring mjpeg-streamer, wait...."
		sudo nohup sh stream.sh > /dev/null 2>1&
		echo "mjpeg-streamer configured."
		echo "Configuring ffmpeg, wait...."
		sleep 5
		sudo nohup sh ffm.sh > /dev/null 2>1&
		echo "ffmpeg configured."
	fi
	mark="b"
done
