

HostID=""
HostID=$(./bin$1/dmphstid | grep  -Eo "IS\:(.*)"| grep -Eo "[A-F0-9]*")
HostIDByHOSTID=$(hostid)
HostIDByHOSTID=${HostIDByHOSTID#0*}
HostIDByHOSTID=${HostIDByHOSTID#x}
HostIDByHOSTID=${HostIDByHOSTID#0*}
HostID=${HostID#0*}
HostID=${HostID#x}
HostID=${HostID#0*}
echo $HostIDByHOSTID, $HostID

HostID=$(        echo $HostID         |tr "[:upper:]" "[:lower:]")
HostIDByHOSTID=$(echo $HostIDByHOSTID |tr "[:upper:]" "[:lower:]")

echo $HostIDByHOSTID, $HostID

if [[ $HostID == $HostIDByHOSTID ]] ; then
   echo "PASS DUMPHOSTID test"
else 
   echo "FAIL DUMPHOSTID test, hostid is not correct:" $HostID, $HostIDByHOSTID
fi
echo "COMPLETE DUMPHOST test"

