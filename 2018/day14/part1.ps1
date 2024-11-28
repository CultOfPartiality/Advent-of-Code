. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"

#The following line is for development
$makethismany = 864801

function Solution {
    param ($makethismany)

    $elf1 = 0
    $elf2 = 1
    $recipies = New-Object System.Collections.ArrayList
    $recipies.Capacity = $makethismany + 10
    [void]$recipies.Add(3)
    [void]$recipies.Add(7)

    while ($recipies.Count -lt $recipies.Capacity) {
        $newMacroRecipie = $recipies[$elf1] + $recipies[$elf2]
        $new1 = [math]::Truncate($newMacroRecipie / 10)
        $new2 = $newMacroRecipie % 10
        if ($new1 -gt 0) {
            [void]$recipies.Add($new1)
        }
        [void]$recipies.Add($new2)
        $elf1 = ($elf1 + 1 + $recipies[$elf1]) % $recipies.Count
        $elf2 = ($elf2 + 1 + $recipies[$elf2]) % $recipies.Count


        # write-host "Round $round - $($recipies -join ",")"
    }
    ($recipies[$makethismany..($makethismany + 9)] | % { [string]$_ } | Join-String).TrimStart("0")


}
Unit-Test  ${function:Solution} 9 5158916779
Unit-Test  ${function:Solution} 5 0124515891
Unit-Test  ${function:Solution} 18 9251071085
Unit-Test  ${function:Solution} 2018 5941429882

$measuredTime = measure-command { $result = Solution 864801 }
Write-Host "Part 1: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta

