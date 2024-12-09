. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"

#The following line is for development
$Path = "$PSScriptRoot/testcases/test1.txt"

function Solution {
    param ($Path)

    # Not sure I'm happy with this, but it runs in ~0.3s so it'll do
    
    # Parse the data, and expand the data into a string
    $data = (get-content $Path).ToCharArray().ForEach({[int]([string]$_)})

    $dataReg = $true
    $id = 0
    $expanded = foreach ($reg in $data) {
        if ($dataReg) {
            @($id) * $reg
            $id++
        }
        else {
            @(-1) * $reg
        }
        $dataReg = -not $dataReg
    }

    # Use an index first empty space, and an index at the last valid data. 
    # While these haven't overlapped, move the data between the two

    $index = $expanded.IndexOf(-1)
    $endex = $expanded.Count - 1
    while ($expanded[$endex] -eq -1) { $endex-- }

    while ($index -lt $endex) {
        $expanded[$index++] = $expanded[$endex]
        $expanded[$endex--] = -1
        while ($expanded[$index] -ne -1) { $index++ }
        while ($expanded[$endex] -eq -1) { $endex-- }
    }

    # Calculate the output hash
    $total = 0
    for ($i = 0; $i -lt $index; $i++) {
        $total += $expanded[$i] * $i
    }
    $total

}
Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test1.txt" 1928
$measuredTime = measure-command { $result = Solution "$PSScriptRoot\input.txt" }
Write-Host "Part 1: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta

