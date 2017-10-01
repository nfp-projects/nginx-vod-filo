<?php
error_reporting(E_ALL);
if(!isset($_REQUEST['output'])) { die('Missing output'); }
//$output = exec("/usr/bin/ffmpeg -y -i rtmp://157.157.65.93:443/filadelfia/stream1 -vcodec copy -acodec copy fftest15.mp4 </dev/null >/dev/null 2>/var/log/ffmpeg.log &");
//$output = exec("/usr/bin/ffmpeg -y -i rtmp://157.157.65.93:443/filadelfia/stream1 -vcodec copy -acodec copy /content/kennslur/".$_REQUEST['output'].".mp4 </dev/null >/dev/null 2>/dev/null &1");
$output = exec("/usr/bin/ffmpeg -y -i 'rtmp://82.221.112.178:1935/live/ljosbrot live=1' -vcodec copy -acodec copy /content/kennslur/".$_REQUEST['output'].".mp4 </dev/null >/dev/null 2>/dev/null &1");
print_r($output);
echo PHP_EOL.'OK START';
?>
<br>
<input type="button" value="Stodva upptoku" onclick="window.location='stop_recording.php';return false;">
