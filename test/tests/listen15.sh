

./bin$1/listen15 2>&1  >/tmp/listen15.txt 2>&1 &
sleep 1
./bin$1/send0015 2>&1  >/tmp/send0015.txt 2>&1

sleep 1

echo "---------------" |cat   /tmp/send0015.txt - /tmp/listen15.txt
rm -f /tmp/send0015.txt /tmp/listen15.txt

