

IPAddress=""
IPAddress=$(./bin$1/ioctl034 | grep  -Eo "is\:(.*)"| grep -Eo "[0-9\.]*")
IPAddressFromConsole=$(/sbin/ifconfig eth0 | grep -Eo 'Bcast:[0-9\.]+' | grep -Eo '[0-9\.]*')


if [[ $IPAddress == $IPAddressFromConsole ]] ; then
   echo "PASS IOCTL034 test"
else 
   echo "FAIL IOCTL034 test, hostid is not correct:" $IPAddress, $IPAddressFromConsole
fi
echo "COMPLETE IOCTL034 test"

