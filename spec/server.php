<?php
$server = preg_replace("#/.*$#", '', $_SERVER['SERVER_SOFTWARE']);
if (preg_match("#^PHP .+ Development Server$#", $server)) {
    $server = 'PHP Development Server';
}

echo $server."\n";
