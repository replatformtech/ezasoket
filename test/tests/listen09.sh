

./bin$1/listen09 2>&1  >/tmp/listen09.txt 2>&1 &
sleep 1
./bin$1/sendto09 2>&1  >/tmp/sendto09.txt 2>&1

sleep 1

echo "----------------" |cat   /tmp/sendto09.txt - /tmp/listen09.txt
rm -f /tmp/sendto09.txt /tmp/listen09.txt

