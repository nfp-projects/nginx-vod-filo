<?php
//echo 'php workings';
?>
<html>
<head>
<title>Upptokustyring</title>
<body>

  <form action="/start_the_recording.php">
  <br />
  Taka upp sem: <input name="output" id="output" type="text" value=""> <input type="submit" id="submit-button" value="Hefja upptoku"> <input type="button" value="Stodva upptoku" onclick="window.location='stop_recording.php';return false;">
  </form>

</body>
</html>
