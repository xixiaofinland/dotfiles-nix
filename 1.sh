wl-screenrec --codec libx264 -f ~/Videos/test.mp4 &
echo $! > /tmp/wl-screenrec.pid
sleep 5
kill -TERM $(cat /tmp/wl-screenrec.pid)
