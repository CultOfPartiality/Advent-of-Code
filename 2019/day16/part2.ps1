. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"

#The following line is for development
$Path = "$PSScriptRoot/testcases/test1.txt"

function Solution {
    param ($Path)

    $InputSignal = (get-content $Path).ToCharArray() | % { [int]"$_" }
    $RealSignal = $InputSignal * 10000

    $MessageOffset = [int]($InputSignal[0..6] -join "")

    function FFT {
        param ($InputSignal)
        $BasePattern = 0, 1, 0, -1
        $result = @()
    
        # For each digit in the input signal...
        for ($i = 0; $i -lt $InputSignal.Count; $i++) {
            $Pattern = $BasePattern | % { @($_) * ($i + 1) }
            $PatternIndex = $i
            $tot = 0
            for ($j = $i; $j -lt $InputSignal.Count; $j++) {
                $PatternIndex = ($PatternIndex + 1) % $Pattern.Count
                $tot += $InputSignal[$j] * $Pattern[$PatternIndex]
            }
            $result += [Math]::ABS($tot % 10)
        }
        $result
    }

    $signal = $RealSignal
    1..100 | % { $signal = FFT -InputSignal $signal }

    [int]($signal[$MessageOffset..($MessageOffset+7)] -join "")

}
Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test4.txt" 84462026
Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test5.txt" 78725270
Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test6.txt" 53553731
$measuredTime = measure-command { $result = Solution "$PSScriptRoot\input.txt" }
Write-Host "Part 2: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta

