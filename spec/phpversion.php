<?php

$version = explode('.',phpversion());
$version = $version[0] . '.' . $version[1];
echo $version."\n";
