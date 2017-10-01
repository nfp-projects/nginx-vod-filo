<?php
$output = shell_exec("/usr/bin/killall -INT ffmpeg");
echo $output;
echo PHP_EOL.'OK';
?>
