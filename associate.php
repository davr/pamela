<body>
<div id="wrapper">
  <a href="http://acemonstertoys.org"><h1 id="top"><span>Ace Monster Toys</span></h1></a>

  <div id="content">
    <h2>Ace Monster Toys PAMELA</h2>
    <div class="caption">
<?php

if(isset($_POST['macaddress']) && isset($_POST['name'])) {
require_once("lib/util.php");
require_once("lib/data.php");

	$mac = trim(strtolower($_POST['macaddress']));
	$name = str_replace(",",".",trim($_POST['name']));
	if($mac == "11:22:33:44:55:66" || $name == "Bob [laptop]") {
		print("ERROR: don't submit default values!");
	} else
	if(strlen($mac) != 17 || !preg_match('/^([0-9a-f]{2,2}:){5,5}[0-9a-f]{2,2}$/', $mac)) {
		print("ERROR: Required mac address format: 01:23:45:67:89:ab<br><br>");
	} else {
		file_put_contents("mac_log.csv",str_replace(array("\r","\n"),array("",""),"$mac,$name")."\n", FILE_APPEND);
		map_add($mac, $name, 30);
		
		print("Thanks!");
		die();
	}
}
?>
      <form method="post" action="associate.php">
        <h3>Add a User</h3>
        <label for="macaddress">MAC Address: <input type="text" id="macaddress" name="macaddress" value="11:22:33:44:55:66"/></label>
        <label for="Name">Name <input type="text" id="name" name="name" value="Bob [laptop]"/></label>
        <input type="submit" id="submit" name="submit" value="Add User" />
      </form>
    </div>
	<p class="help">How to find your MAC address:<br>
<ul>
<li><a href="http://www.wikihow.com/Find-the-MAC-Address-of-Your-Computer#Windows">Windows</a></li>
<li><a href="http://www.wikihow.com/Find-the-MAC-Address-of-Your-Computer#Linux">Linux</a></li>
<li><a href="http://www.wikihow.com/Find-the-MAC-Address-of-Your-Computer#Mac_OS_X">Mac OS X</a></li>
<li><a href="http://it.usu.edu/htm/faq/faq_q=3979">Android</a></li>
<li><a href="http://hathology.com/2007/07/apple-iphone-mac-address/">iPhone</a></li>
</ul>
</p>
    <p class="footer">To report problems or ask for help/access, contact <a href="http://twitter.com/davr">David R</a></p>
  </div>

</div>
</body>
</html>

