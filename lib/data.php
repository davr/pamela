<?php
/*
    Copyright 2010 Pieter Iserbyt

    This file is part of Pamela.

    Pamela is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    Pamela is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with Pamela.  If not, see <http://www.gnu.org/licenses/>.
*/
require_once("lib/db.php");

function data_check_table() {
  static $table_exists = FALSE;

  // already checked? skip...
  if ($table_exists == TRUE) {
    return;
  }

  // get db handle
  $db = get_db();

  // already in db? skip and remember...
  $q = $db->query("select name from sqlite_master where type='table' and name='data'"); 
  if ($q->fetchArray()) {
    $table_exists = TRUE;
    return;
  }

  // create the table and remember...
  $table_exists =  $db->exec("create table data (data text unique on conflict replace, committime integer)");
  $db->exec("create table mapping (data text, name text, priority integer)");
}

function data_get() {
	$results = array();
  data_check_table(); 
	$db = get_db();
	$q = $db->query("select d.data from data as d
where d.committime > strftime('%s','now') - ".DATA_TTL);
	if (!$q) return $results;
	while($row = $q->fetchArray(SQLITE3_ASSOC)) {
		$results[] = $row['data'];
	}
	$r2 = array();
	foreach($results as $item) {
		$i = $db->escapeString($item);
		$q = $db->query("select name from mapping where data = '".$i."' order by priority desc");
		if($q) {
			$row = $q->fetchArray(SQLITE3_ASSOC);
			if($row && isset($row['name']) && strlen($row['name'])>2) {
				$item = $row['name'];
			}
		}
		$r2[] = $item;
	}
		
	return $r2;
}

function data_add($data) {
	$db = get_db();
  data_check_table(); 
	$data = $db->escapeString($data);
  #echo "insert or replace into data values (\"$data\", strftime('%s','now'))\n";
	$result = $db->exec("insert or replace into data values (\"$data\", strftime('%s','now'))");
  if (!$result)
    echo "ERROR: ".$db->lastErrorMsg()."\n";
}

function map_add($data, $name, $pri) {
	$db = get_db();
  data_check_table(); 
	$data = $db->escapeString($data);
	$name = $db->escapeString($name);
	$pri = intval($pri);
  #echo "insert or replace into data values (\"$data\", strftime('%s','now'))\n";
	$db->exec("delete from mapping where data='$data' AND priority=$pri");
	$result = $db->exec("insert into mapping (data,name,priority) values ('$data', '$name', $pri)");
  if (!$result)
    echo "ERROR: ".$db->lastErrorMsg()."\n";
}

function data_purge() {
	$db = get_db();
  data_check_table(); 
	return $db->exec("delete from data where committime <= strftime('%s','now') - ".DATA_TTL);
}
