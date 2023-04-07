

IPAddress=""
IPAddress=$(./bin$1/ioctl033 | grep  -Eo "is\:(.*)"| grep -Eo "[0-9\.]*")
IPAddressFromConsole=$(/sbin/ifconfig eth0 | grep -Eo 'addr:[0-9\.]+' | grep -Eo '[0-9\.]*')


if [[ $IPAddress == $IPAddressFromConsole ]] ; then
   echo "PASS IOCTL033 test"
else 
   echo "FAIL IOCTL033 test, hostid is not correct:" $IPAddress, $IPAddressFromConsole
fi
echo "COMPLETE IOCTL033 test"

