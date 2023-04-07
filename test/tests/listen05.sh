

./bin$1/listen05 2>&1  >/tmp/listen05.txt 2>&1 &
sleep 1
./bin$1/writev05 2>&1  >/tmp/writev05.txt 2>&1

sleep 1

echo "----------------------" |cat   /tmp/writev05.txt - /tmp/listen05.txt
rm -f /tmp/writev05.txt /tmp/listen05.txt

