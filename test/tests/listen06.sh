

./bin$1/listen06 2>&1  >/tmp/listen06.txt 2>&1 &
sleep 1
./bin$1/sendto06 2>&1  >/tmp/sendto06.txt 2>&1

sleep 1

echo "---------------" |cat   /tmp/sendto06.txt - /tmp/listen06.txt
rm -f /tmp/sendto06.txt /tmp/listen06.txt

