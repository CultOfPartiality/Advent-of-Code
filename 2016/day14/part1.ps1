. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"

#The following line is for development
$Path = "$PSScriptRoot/testcases/test1.txt"

#function Solution {
#    param ($Path)


$salt = get-content $Path
$index = 0
$validKeys = @()
$prev1000Hashes = @()

while($validKeys.Count -ne 64){
    $newHash = (MD5 $salt+$index).ToLower()
    
    if($prev1000Hashes.Count -eq 1000){
        $checkHash = $prev1000Hashes[999]
        $prev1000Hashes = $newHash + $prev1000Hashes[0..998]
        if($checkHash -notmatch "(.)\1\1(?<!\1)"){continue}


    }
    else{
        $prev1000Hashes = $newHash + $prev1000Hashes[0..998]
    }
    
}
    
#}
#Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test1.txt" x
#$measuredTime = measure-command {$result = Solution "$PSScriptRoot\input.txt"}
#Write-Host "Part 1: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta

