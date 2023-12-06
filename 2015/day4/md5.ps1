
function MD5 {
    param ([string]$in)
    
    $stringAsStream = [System.IO.MemoryStream]::new()
    $writer = [System.IO.StreamWriter]::new($stringAsStream)
    $writer.write($in);
    $writer.Flush();
    $stringAsStream.Position = 0
    Get-FileHash -InputStream $stringAsStream -Algorithm MD5| Select-Object -ExpandProperty Hash
}

$inputStr = 'bgvyzdsv'
$ans = 0
while ($true) {
    $hash = MD5 -in ($inputStr+$ans)
    if($hash -match '^00000'){
        break
    }
    if($ans % 1000 -eq 0){
        Write-Host "Checked up to $ans"
    }
    $ans++
}
write-host "$ans produces $hash"
#$ans = 254575

#part 2
while ($true) {
    $hash = MD5 -in ($inputStr+$ans)
    if($hash -match '^000000'){
        break
    }
    if($ans % 1000 -eq 0){
        Write-Host "Checked up to $ans"
    }
    $ans++
}
write-host "$ans produces $hash"
#$ans = 1038736