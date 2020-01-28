<?php

ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

$php_version = preg_replace("/^\d\d/", '', $_SERVER['SERVER_PORT']);
require_once "tmp_vars_$php_version.php";

// Disables index.php as index file
if ( ! preg_match("#\.php$#", $_SERVER['REQUEST_URI']) && preg_match("#/index\.php$#", $_SERVER['SCRIPT_NAME'])) {
    $_SERVER['SCRIPT_NAME'] = preg_replace("#/index\.php$#", '', $_SERVER['SCRIPT_NAME']);
}

$path = $_SERVER["DOCUMENT_ROOT"].'/'.$_SERVER['SCRIPT_NAME'];

// custom router
if (file_exists($_SERVER["DOCUMENT_ROOT"].'/php-webserver-router.php')) {
    $returned = require $_SERVER["DOCUMENT_ROOT"].'/php-webserver-router.php';
    if ($returned !== null) {
        return $returned;
    }
}

if (isset($_GET['phpinfo-router'])) {
    phpinfo();
    exit;
}

if (isset($_GET['env-router'])) {
    var_dump($_SERVER);
    exit;
}

if (! file_exists($path)) {
    return false; // 404 if no output buffer and file not found in doc root
}
elseif (is_dir($path)) {
    // autoindex
    require_once __DIR__ . '/php-webserver-index.phtml';
}
elseif (file_exists($path)) {
    // + display text files
    // + run php files
    // + return others normally (dowload / display dpending on the browser)
    $finfo = finfo_open(FILEINFO_MIME_TYPE);
    $mime = finfo_file($finfo, $path);
    finfo_close($finfo);
    if ($mime == 'text/x-php') {
        return false;
    }
    
    if (strpos($mime, 'text/x-') === 0) {
        header("Content-Type: text/plain");
    }
    else {
        header("Content-Type: $mime");
    }
    require $path;
    return true;
}
