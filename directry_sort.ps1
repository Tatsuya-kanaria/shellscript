$items = Get-ChildItem ./ -Recurse -File

if (Test-Path result.txt) {
    Remove-Item ./result.txt
}

foreach ($item in $items) {
    if ($item.extension -ne ".jww") {
        continue
    }
    $item.fullname + " -i 0.1" >> result.txt
}

if (Test-Path result.txt) {
    Get-content ./result.txt | sort-object -property {$_.split("/")[4]}, {$_.split("/")[5]}, {$_.split("/")[6]}

}
