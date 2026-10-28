. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"

#The following line is for development
$Path = "$PSScriptRoot/testcases/test2.txt"

function Solution {
    param ($Path)

    function generate-indexes {
        param($rawIndex, $floatingBits)
        $indexes = $rawIndex

        foreach ($bit in $floatingBits) {
            $bitMask = (([uint64]1) -shl $bit)
            $indexes = $indexes | % {
                $_ -bor $bitMask
                $_ -band (-bnot $bitMask)
            }
        }
        $indexes
    }


    $mem = @{}
    [UInt64]$SetMask = 0
    $mask = ""
    $floatingBits = @()

    foreach ( $row in (get-content $Path)) {
        if ($row -match "mask") {
            $mask = $row.Substring(7)
            # Memory index bits:
            #   0 = unchanged
            #   1 = override with 1
            #   x = both 1 and 0

            $SetMask = [Convert]::ToUInt64( ($mask -replace "X", "0"), 2) #We'll use bitwise OR
            $floatingBits = @()
            $index = -1
            do {
                $index = $mask.IndexOf("X", ($index + 1))
                if ($index -ne -1) { $floatingBits += $index }
            }while ($index -ne -1)
            $floatingBits = $floatingBits | % { 35 - $_ }
        }
        else {
            $matchInfo = ([regex]::Match($row, "\[(\d*)\] = (\d*)"))
            $rawIndex = [uint64]$matchInfo.Groups[1].Value -bor $SetMask
            $value = [int]$matchInfo.Groups[2].Value
            generate-indexes $rawIndex $floatingBits | % {
                $mem[$_] = $value
            }
        }
    }

    $mem.Values | Sum-Array

}
Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test3.txt" 400
Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test2.txt" 208
$measuredTime = measure-command { $result = Solution "$PSScriptRoot\input.txt" }
Write-Host "Part 2: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta