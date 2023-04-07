

./bin$1/listen16 2>&1  >/tmp/listen16.txt 2>&1 &
sleep 1
./bin$1/send0016 2>&1  >/tmp/send0016.txt 2>&1

sleep 1

echo "---------------" |cat   /tmp/send0016.txt - /tmp/listen16.txt
rm -f /tmp/send0015.txt /tmp/listen15.txt

