<?php
/**
 * @see https://stackoverflow.com/questions/2510434/format-bytes-to-kilobytes-megabytes-gigabytes
 */
function format_bytes($bytes, $precision = 2) { 
    $units = array('B', 'K', 'M', 'G', 'T'); 

    $bytes = max($bytes, 0); 
    $pow = floor(($bytes ? log($bytes) : 0) / log(1024)); 
    $pow = min($pow, count($units) - 1); 

    // Uncomment one of the following alternatives
    // $bytes /= pow(1024, $pow);
    // $bytes /= (1 << (10 * $pow)); 

    return round($bytes, $precision) . $units[$pow]; 
}

/**
 */
function inline_file($path) {
    $mimes = [
        'gif' => 'application/gif',
        'png' => 'application/png',
        'jpg' => 'application/jpg',
        'jpeg' => 'application/jpg',
        'woff' => 'application/font-woff',
        'woff2' => 'application/font-woff2',
        'ttf'  => 'application/font-ttf',
        'eot'  => 'application/vnd.ms-fontobject',
        'otf'  => 'application/font-otf',
        'svg'  => 'image/svg+xml',
    ];
    $ext    = pathinfo($path, PATHINFO_EXTENSION);
    $data   = file_get_contents($path);
    $base64 = 'data:' . $mimes[$ext] . ';base64,' . base64_encode($data);
    return $base64;
}

/**
 * @see https://www.php.net/manual/en/function.fileperms.php
 */
function readable_fileperms($filepath) {
    $perms = fileperms($filepath);
    switch ($perms & 0xF000) {
        case 0xC000: // socket
            $info = 's';
            break;
        case 0xA000: // symbolic link
            $info = 'l';
            break;
        case 0x8000: // regular
            $info = 'r';
            break;
        case 0x6000: // block special
            $info = 'b';
            break;
        case 0x4000: // directory
            $info = 'd';
            break;
        case 0x2000: // character special
            $info = 'c';
            break;
        case 0x1000: // FIFO pipe
            $info = 'p';
            break;
        default: // unknown
            $info = 'u';
    }

    // Owner
    $info .= (($perms & 0x0100) ? 'r' : '-');
    $info .= (($perms & 0x0080) ? 'w' : '-');
    $info .= (($perms & 0x0040) ?
                (($perms & 0x0800) ? 's' : 'x' ) :
                (($perms & 0x0800) ? 'S' : '-'));

    // Group
    $info .= (($perms & 0x0020) ? 'r' : '-');
    $info .= (($perms & 0x0010) ? 'w' : '-');
    $info .= (($perms & 0x0008) ?
                (($perms & 0x0400) ? 's' : 'x' ) :
                (($perms & 0x0400) ? 'S' : '-'));

    // World
    $info .= (($perms & 0x0004) ? 'r' : '-');
    $info .= (($perms & 0x0002) ? 'w' : '-');
    $info .= (($perms & 0x0001) ?
                (($perms & 0x0200) ? 't' : 'x' ) :
                (($perms & 0x0200) ? 'T' : '-'));

    return $info;
}

/**
 * Get font awesome file icon class for specific MIME Type
 * @see https://gist.github.com/guedressel/0daa170c0fde65ce5551
 * @see https://gist.github.com/colemanw/9c9a12aae16a4bfe2678de86b661d922
 */
function fontawesome_class_by_mime($mime_type) {
    // List of official MIME Types: http://www.iana.org/assignments/media-types/media-types.xhtml
    $icon_classes = array(
        // Media
        'image' => 'fa-file-image',
        'audio' => 'fa-file-audio',
        'video' => 'fa-file-video',
        // Documents
        'application/pdf' => 'fa-file-pdf',
        'application/msword' => 'fa-file-word',
        'application/vnd.ms-word' => 'fa-file-word',
        'application/vnd.oasis.opendocument.text' => 'fa-file-word',
        'application/vnd.openxmlformats-officedocument.wordprocessingml' => 'fa-file-word',
        'application/vnd.ms-excel' => 'fa-file-excel',
        'application/vnd.openxmlformats-officedocument.spreadsheetml' => 'fa-file-excel',
        'application/vnd.oasis.opendocument.spreadsheet' => 'fa-file-excel',
        'application/vnd.ms-powerpoint' => 'fa-file-powerpoint',
        'application/vnd.openxmlformats-officedocument.presentationml' => 'fa-file-powerpoint',
        'application/vnd.oasis.opendocument.presentation' => 'fa-file-powerpoint',
        'text/plain' => 'fa-file-alt',
        'text/html' => 'fa-file-code',
        'application/json' => 'fa-file-code',
        'text/x-makefile' => 'fa-file-code',
        'text/x-shellscript' => 'fa-file-code',
        'text/x-diff' => 'fa-file-code',
        'text/x-php' => 'fa-file-code',
        // Archives
        'application/gzip' => 'fa-file-archive',
        'application/zip' => 'fa-file-archive',
    );
    
    foreach ($icon_classes as $text => $icon) {
        if (strpos($mime_type, $text) === 0) {
            return $icon;
        }
    }
    
    // return 'fa-file';
    return 'fa-question';
}

/**
 */
function file_description($filepath) {
    if (is_dir($filepath)) {
        return '-';
    }
    $tags = get_meta_tags($filepath);
    return $tags['DESCRIPTION'] ?? '-';
}

/**
 */
function column_link($column) {
    global $requested_sorting_column, $requested_sorting_order;

    if ($requested_sorting_column == $column['id']) {
        $next_order = $requested_sorting_order == 'asc'
                    ? 'desc' : 'asc';
    }
    else {
        $next_order = 'asc';
    }

    return '?column=' . $column['id']
         . '&order=' . $next_order ;
}

/**
 */
function column_sort_icon($column) {
    global $requested_sorting_column, $requested_sorting_order;


    if ($requested_sorting_column != $column['id']) {
        return 'fa-sort';
    }
    
    return $requested_sorting_order == 'asc'
        ? 'fa-sort-down' : 'fa-sort-up';
}

/**
 */
function breadcrumb($path) {
    $parts = $path == '/' ? [''] : explode('/', $path);
    $parents = [];
    $out = '';
    foreach ($parts as $part) {
        $parents[] = $part;
        $url = implode('/', $parents) ? : '/';
        $out .= "<a href='$url'>$part/</a>";
    }
    return $out;
}

/**
 * Replaces all url(...) content by base64 data:... encoded content.
 */
function inlinify_css($path) {
    $build_file = __DIR__ . '/build/' . str_replace("/", '_', $path);
    if (file_exists($build_file) && filemtime($build_file) > filemtime($path)) {
        return file_get_contents($build_file);
    }
    
    $content   = file_get_contents($path);
    $directory = dirname($path);
    $content =  preg_replace_callback("#url\(([^)]*)\)#im", function($matches) use ($directory) {
        $url = $matches[1];
        if (preg_match("#(\"|')(.*)(\"|')#", $url, $escape_matches)) {
            $unescaped_url = stripslashes($escape_matches[2]);
        }
        else {
            $unescaped_url = $url;
        }

        $url_parts = parse_url($unescaped_url);
        
        $url_path = $directory . '/' . $url_parts['path'];

        if ( ! file_exists($url_path)) {
            return $string;
        }
        
        return "url('" . inline_file($url_path) . "')";
    }, $content);

    file_put_contents($build_file, $content);

    return $content;
}
