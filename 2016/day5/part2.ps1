. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"

#The following line is for development
# $Path = "$PSScriptRoot/testcases/test1.txt"
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
    Get-FileHash -InputStream $stringAsStream -Algorithm MD5 | Select-Object -ExpandProperty Hash
}

$inputStr = $data
$index = 0
if ($data -eq 'abc') {
    $index = 3200000
}
$answerCount = 0
$ans = "        ".ToCharArray()
while ($answerCount -lt 8) {
    $hash = MD5 -in ($inputStr + $index)
    if ( $hash -match '^00000' -and [int]$hash[5] -le 55) {
        $nextCharIndex = [int]$hash[5].ToString()
        if ($ans[$nextCharIndex] -eq " ") {
            write-host "$index produces $hash - Password index $($hash[5]) is $($hash[6])"
            $ans[$nextCharIndex] = $hash[6]
            $answerCount++
        }
        else {
            write-host "$index produces $hash - Password index $($hash[5]) already found though"
        }
    }
    if ($index % 100000 -eq 0) {
        $currentans = $ans -join ""
        Write-Host "Checked up to input $($inputStr+$index), current progress: $currentans"
    }
    $index++
}
$ans = $ans -join ""
write-host "Password: $ans"
#$ans = answerCount

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
