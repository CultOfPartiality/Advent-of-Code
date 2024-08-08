. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"

#The following line is for development
$Path = "$PSScriptRoot/testcases/test1.txt"
$Path = "$PSScriptRoot/input.txt"


#function Solution {
#    param ($Path)


$data = get-content $Path

function MD5 {
    param ([string]$in)
    
    $stringAsStream = [System.IO.MemoryStream]::new()
    $writer = [System.IO.StreamWriter]::new($stringAsStream)
    $writer.write($in);
    $writer.Flush();
    $stringAsStream.Position = 0
    Get-FileHash -InputStream $stringAsStream -Algorithm MD5| Select-Object -ExpandProperty Hash
}

$inputStr = $data
$index = 0
$ans = ""
while ($ans.Length -lt 8) {
    $hash = MD5 -in ($inputStr+$index)
    if($hash -match '^00000'){
        write-host "$index produces $hash - Next char is $($hash[5])"
        $ans += $hash[5]
    }
    if($index % 10000 -eq 0){
        Write-Host "Checked up to $index"
    }
    $index++
}
write-host "Password: $($ans.ToLower())"
#$ans = f97c354d

# #part 2
# while ($true) {
#     $hash = MD5 -in ($inputStr+$ans)
#     if($hash -match '^000000'){
#         break
#     }
#     if($ans % 1000 -eq 0){
#         Write-Host "Checked up to $ans"
#     }
#     $ans++
# }
# write-host "$ans produces $hash"
#$ans = 1038736


#}

#Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test1.txt" x
#$result = Solution "$PSScriptRoot\input.txt"
#Write-Host "Part 1: $result" -ForegroundColor Magenta
