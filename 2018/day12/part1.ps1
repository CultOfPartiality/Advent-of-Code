. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"

#The following line is for development
$Path = "$PSScriptRoot/testcases/test1.txt"

function Solution {
    param ($Path)

    # Turn input into an index into an array. Then for each generation generate the index to see if plant survives
    # Preallocate negative indexes (2* (# of rounds)+2) and extra indexes (also the same)

    $data = get-content $Path
    $initialState = $data[0].TrimStart("initial state: ")
    $instructions = New-Object "char[]" ([System.Math]::Pow(2, 5))
    for ($i = 0; $i -lt $instructions.Length; $i++) {
        $instructions[$i] = '0'
    }
    $data | select -Skip 2 | % {
        $layout, $outcome = $_ -split " => "
        $value = $layout.ToCharArray() | % { $_ -eq "#" ? "1" : "0" } | Join-String
        $value = [System.Convert]::ToInt32($value, 2)
        $instructions[$value] = $outcome -eq "#" ? '1' : '0'
    }


    $zeroIndex = 40 + 2
    $pots = New-Object "char[]" ($zeroIndex + $initialState.length + $zeroIndex)
    for ($i = 0; $i -lt $pots.Length; $i++) {
        $pots[$i] = '0'
    }
    for ($i = 0; $i -lt $initialState.Length; $i++) {
        $pots[$zeroIndex + $i] = $initialState[$i] -eq "#" ? '1' : '0'
    }

    # write-host "start: "($pots[42..80] -join "")
    foreach ($round in 1..20) {
        $nextPots = $pots.Clone()
        foreach ($potIndex in 2..($pots.Count - 3)) {
            $hash = [convert]::ToInt32( ($pots[($potIndex - 2)..($potIndex + 2)] -join '') , 2)
            $nextPots[$potIndex] = $instructions[$hash]
        }
        $pots = $nextPots
        # write-host "Round $round"($pots[42..80] -join "")
    }

    $total = 0
    for ($i = 0; $i -lt $pots.Length; $i++) {
        $total += $pots[$i] -eq '1' ? $i - $zeroIndex : 0
    }

    $total

}
Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test1.txt" 325
$measuredTime = measure-command { $result = Solution "$PSScriptRoot\input.txt" }
Write-Host "Part 1: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta

