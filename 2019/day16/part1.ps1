. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"

#The following line is for development
$Path = "$PSScriptRoot/testcases/test1.txt"

function Solution {
    param ($Path)

    $InputSignal = (get-content $Path).ToCharArray() | % { [int]"$_" }

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

    $signal = $InputSignal
    1..100 | % { $signal = FFT -InputSignal $signal }

    [int]($signal[0..7] -join "")

}
Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test1.txt" 24176176
Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test2.txt" 73745418
Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test3.txt" 52432133
$measuredTime = measure-command { $result = Solution "$PSScriptRoot\input.txt" }
Write-Host "Part 1: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta

