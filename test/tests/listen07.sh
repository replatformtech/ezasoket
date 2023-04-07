

./bin$1/listen07 2>&1  >/tmp/listen07.txt 2>&1 &
sleep 1
./bin$1/sendmsg7 2>&1  >/tmp/sendmsg7.txt 2>&1

sleep 1

echo "---------------" |cat   /tmp/sendmsg7.txt - /tmp/listen07.txt
rm -f /tmp/sendmsg7.txt /tmp/listen07.txt

