

./bin$1/listen11 2>&1  >/tmp/listen11.txt 2>&1 &
sleep 1
./bin$1/write011 2>&1  >/tmp/write011.txt 2>&1

sleep 1

echo "----------------------" |cat   /tmp/write011.txt - /tmp/listen11.txt
rm -f /tmp/write011.txt /tmp/listen11.txt

