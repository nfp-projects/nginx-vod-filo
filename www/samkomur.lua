local files = {}

local function ends_with(str, ending)
  return ending == "" or str:sub(-#ending) == ending
end

local p = io.popen('ls -a "/content/kennslur"')
for file in p:lines() do
  if ends_with(file, '.mp4') and not ends_with(file, 'klippt.mp4') then
    table.insert(files, file)
  end
end

table.sort(files, function(a, b) return b < a end)

local total = 6

if total > #files then
  total = #files
end

ngx.say([[
<!doctype html>
<html lang="is" dir="ltr" data-cast-api-enabled="true">

<head>
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Filadelfia</title>
    <style>
    * {
        -webkit-box-sizing: border-box;
        Box-Sizing: border-box;
    }

    HTML,
    BODY,
    #main {
        Margin: 0;
        Padding: 0;
        Width: 100%;
        Height: 100%;
        Overflow: hidden;
        Background: #000;
    }

    #player {
        Margin: 0 auto;
        Overflow: hidden;
    }
    </style>
</head>

<body>
    <main>
        <div id="player">
            <div id="playerdiv">
            </div>
        </div>
    </main>
    <script src="//content.jwplatform.com/libraries/Xl6C9H3O.js"></script>
    <script>
    function resizePlayer(player) {
        var D = document;
        var player = D.getElementById('player');
        var srcWidth = 1280;
        var srcHeight = 720;
        var maxWidth = Math.max(Math.max(D.body.scrollWidth, D.documentElement.scrollWidth), Math.max(D.body.offsetWidth, D.documentElement.offsetWidth), Math.max(D.body.clientWidth, D.documentElement.clientWidth));
        var maxHeight = Math.min(Math.min(D.body.scrollHeight, D.documentElement.scrollHeight), Math.min(D.body.offsetHeight, D.documentElement.offsetHeight), Math.min(D.body.clientHeight, D.documentElement.clientHeight));

        var ratio = Math.min(maxWidth / srcWidth, maxHeight / srcHeight);

        player.style.width = Math.round(srcWidth * ratio) + 'px';
        player.style.height = Math.round(srcHeight * ratio) + 'px';
    }

    window.onload = function() {

        resizePlayer('player');

        jwplayer('playerdiv').setup({
            /*
    sources: [{
                      file: stream,
          //},{file: 'http://filadelfia.rcx.is/notfound.mp4',
                }],
    */

            playlist: [
]])
for i = 1, total do
  ngx.say('            { file: "http://http://storage01.nfp.is//kennslur/' .. files[i] .. '/master.m3u8", title: "' .. files[i] .. '" }, ')
end
ngx.say([[
            ],

            image: '',
            width: '100%',
            height: '100%',
            autostart: true,
            aspectratio: '16:9',
            stretching: 'exactfit',
            androidhls: 'true',
            fallback: 'false',
            primary: 'flash'
        });
        var playerInstance = jwplayer('playerdiv');
        playerInstance.onError(function(e) {
            playerInstance.load({ file: 'http://http://storage01.nfp.is//notfound.mp4' });
            playerInstance.play(true);
        });

    }
    window.onresize = function() { resizePlayer('player'); };
    </script>
    <script>
    (function(i, s, o, g, r, a, m) {
        i['GoogleAnalyticsObject'] = r;
        i[r] = i[r] || function() {
            (i[r].q = i[r].q || []).push(arguments)
        }, i[r].l = 1 * new Date();
        a = s.createElement(o),
            m = s.getElementsByTagName(o)[0];
        a.async = 1;
        a.src = g;
        m.parentNode.insertBefore(a, m)
    })(window, document, 'script', '//www.google-analytics.com/analytics.js', 'ga');

    ga('create', 'UA-68293245-1', 'auto');
    ga('send', 'pageview');
    </script>
</body>

</html>
]])
