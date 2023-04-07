

./bin$1/give0050 2>&1  >/tmp/give0050.txt 2>&1 &
sleep 1
./bin$1/call0050 2>&1  >/tmp/call0050.txt 2>&1

sleep 5

echo "------------------" |cat /tmp/give0050.txt - /tmp/call0050.txt
rm -f /tmp/give0050.txt /tmp/call0050.txt

ps -u $USER |while read Pid t1 t2 Command
do
   if [[ $Command == "give0050" ]]
   then
      kill $Pid
   fi
done

