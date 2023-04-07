

HostName=""
HostName=$(./bin$1/dumphost | grep  -Eo "is\:(.*)" | grep  -Eo "\:([^[:space:]]*)" | grep  -Eo "([^\:]*)")
echo $HostName

HostNameByUName=$(uname -n)

if [[ $HostName == $HostNameByUName ]] ; then
   echo "PASS DUMPHOST test"
else 
   echo "FAIL DUMPHOST test, hostname is not correct", $HostName, $HostNameByUName
fi
echo "COMPLETE DUMPHOST test"

