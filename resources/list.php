<?php
$filename = "MeleeLib.tres";
$lib="MeleeLib";
if (file_exists($filename)) {
    $s=strlen("resource_name = ");
    $file = fopen($filename, "r");
    $list = [];
    $text = "";
    while (($line = fgets($file)) !== false) {
        $line=trim($line);
        if (strpos(trim($line), "resource_name") === 0) {
            echo substr($line,$s)."\n";
            $list[]="$lib/".substr($line,$s+1,-1);
        }
    }
    file_put_contents("meleelib.json",json_encode($list,JSON_PRETTY_PRINT));
    fclose($file);
} else {
    echo "File not found.";
}
