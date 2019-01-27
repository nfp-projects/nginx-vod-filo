local f = assert(io.popen("/usr/bin/killall -INT ffmpeg", "r"))
os.execute("sleep 1")
local s = assert(f:read('*all'))
ngx.say(s:gsub("\n", "\n<br>"))
ngx.say([[
<br>
]])
--[[
<?php
$output = shell_exec("/usr/bin/killall -INT ffmpeg");
echo $output;
echo PHP_EOL.'OK';
?>
]]
