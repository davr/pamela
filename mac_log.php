<?php
// Dumps out the database of mac to name mappings

require_once("config.php");
require_once("lib/data.php");
header("Content-type: text/plain");

$db = get_db();
$q = $db->query("select * from mapping order by data, priority asc");
while($row = $q->fetchArray(SQLITE3_ASSOC)) {
	print($row['priority'].",".$row['data'].",".$row['name']."\n");
}

