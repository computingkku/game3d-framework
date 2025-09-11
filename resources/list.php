<?php
$filename = "knight_animations.tres";
if (file_exists($filename)) {
    $s=strlen("resource_name = ");
    $file = fopen($filename, "r");
    while (($line = fgets($file)) !== false) {
        if (strpos(trim($line), "resource_name") === 0) {
            echo substr($line,$s);
        }
    }
    fclose($file);
} else {
    echo "File not found.";
}
