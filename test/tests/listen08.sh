

./bin$1/listen08 2>&1  >/tmp/listen08.txt 2>&1 &
sleep 1
./bin$1/sendmsg8 2>&1  >/tmp/sendmsg8.txt 2>&1

sleep 1

echo "----------------" |cat   /tmp/sendmsg8.txt - /tmp/listen08.txt
rm -f /tmp/sendmsg8.txt /tmp/listen08.txt

