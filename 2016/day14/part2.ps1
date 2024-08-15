. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"

#The following line is for development
$Path = "$PSScriptRoot/testcases/test1.txt"

$md5 = New-Object -TypeName System.Security.Cryptography.MD5CryptoServiceProvider
$utf8 = New-Object -TypeName System.Text.UTF8Encoding
function MD5_Alt {
    param($inStr)
    [System.BitConverter]::ToString($md5.ComputeHash($utf8.GetBytes($inStr))).ToLower() -replace "-",""
}


function Solution {
    param ($Path)


    $salt = get-content $Path
    $index = 0
    $validKeys = @()
    $prev1000Hashes = @()

    while ($validKeys.Count -ne 64) {
        
        if($index % 1000 -eq 0){
            write-host "$index hashes checked, $($validKeys.Count) keys found so far"
        }

        $inStr = ($salt + $index)
        # 0..2016 | % { $inStr = (MD5 $inStr).ToLower() }
        0..2016 | % { $inStr = ([System.BitConverter]::ToString($md5.ComputeHash($utf8.GetBytes($inStr))).ToLower().Replace("-","")) }
        $newHash = $inStr
        $index++
    
        if ($prev1000Hashes.Count -eq 1000) {
            $checkHash = $prev1000Hashes[0]
            $prev1000Hashes = $prev1000Hashes[1..999] + $newHash
            # if ($checkHash -notmatch "(.)(?!\1)(.)\2{2}(?!\2)|^(.)\3{2}(?!\3)") { continue } #Exclude where xAAAx not found
            if ($checkHash -notmatch "(.)\1{2}") { continue } #Exclude where AAA not found
            # $char = $Matches.Count -eq 3 ? $Matches[2] : $Matches[3]
            $char = $Matches[1]
            # $matchingHashes = $prev1000Hashes -match "(.)(?!\1)($char){5}(?!\2)|^($char){5}(?!\3)"
            $matchingHashes = $prev1000Hashes -match "($char){5}"
            if ($matchingHashes) {
                # write-host "Found index $($index -1001): $checkHash -> $matchingHashes"
                #found a run of 5 chars
                $validKeys += $checkHash
            }
        }
        else {
            $prev1000Hashes += $newHash
        }
    }
    $index - 1000 - 1
    
}
Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test1.txt" 22551
$measuredTime = measure-command { $result = Solution "$PSScriptRoot\input.txt" }
Write-Host "Part 1: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta

