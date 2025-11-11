. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"

#The following line is for development
$Path = "$PSScriptRoot/testcases/test1.txt"

function Solution {
    param ($Path)

    $InputSignal = (get-content $Path).ToCharArray() | % { [int]"$_" }
    $RealSignal = $InputSignal

    $MessageOffset = [int]($InputSignal[0..6] -join "")

    #This doesn't work. It might for the first round, but we don't know the next round will be the same pattern of duplicates input signals..
    function FFT_NotIT {
        param ($InputSignal)
        $BasePattern = 0, 1, 0, -1
        $result = @()
        $InputSignalLong = $InputSignal  * 10000

        # For each digit in the input signal...
        for ($i = 0; $i -lt $InputSignalLong.Count; $i++) {
            $Pattern = $BasePattern | % { @($_) * ($i + 1) }
            
            # Work out how many rounds of the signal are required for the pattern to line up
            # e.g. for a length of 650, for the first digit (pattern length of 4) we'll need to do 2 rounds.    Then we can just multiply that by 10000/2 = 5000
            #                           for the second digit (pattern length of 8) we'll need to do 4 rounds.   Then we can just multiply that by 10000/4 = 2500
            #                           for the third digit (pattern length of 12) we'll need to do 6 rounds.   Then we can just multiply that by 10000/6 = 1666.666.....?
            #                           for the fourth digit (pattern length of 16) we'll need to do 8 rounds.  Then we can just multiply that by 10000/8 = 1250
            #                           for the fifth digit (pattern length of 20) we'll need to do 2 rounds.   Then we can just multiply that by 10000/2 = 5000
            #       Digit | Pattern Len | Rounds to whole num | Multiply
            #       ------+-------------+---------------------+----------------
            #       0     | 4           | 2                   | 10000/2  = 5000
            #       1     | 8           | 4                   | 10000/4  = 2500
            #       2     | 12          | 6                   | 10000/6  = 1666, then do (10000 - 1666*6) = 4 repeats of the input signal more
            #       3     | 16          | 8                   | 10000/8  = 1250
            #       4     | 20          | 2                   | 10000/2  = 5000
            #       5     | 24          | 12                  | 10000/12 = 833, then do 4 repeats of the input signal more
            #       6     | 28          | 14                  | 10000/14 = 714, then do 4 repeats of the input signal more
            #       7     | 32          | 16                  | 10000/16 = 625
            

            $RoundsOfInput = (lcm $InputSignal.Count $Pattern.Count)/$InputSignal.Count
            $MultiplyFactorTemp = [Math]::DivRem(10000,$RoundsOfInput)
            $Multiply = $MultiplyFactorTemp.Item1
            $ExtraInputSignalsAfter = $MultiplyFactorTemp.Item2
            # write-host "Digit $i | Pattern length $($Pattern.Count) | Rounds of Input Signal that line up with pattern: $RoundsOfInput | Multiply: $Multiply | Extra Input Signals: $ExtraInputSignalsAfter"
            
            #Do the initial round of input signals
            $InputSignalDuplicated = $InputSignal * $RoundsOfInput
            $PatternIndex = $i
            $tot = 0
            for ($j = 0; $j -lt $InputSignalDuplicated.Count; $j++) {
                $PatternIndex = ($PatternIndex + 1) % $Pattern.Count
                $tot += $InputSignalDuplicated[$j] * $Pattern[$PatternIndex]
            }
            $tot = ([Math]::ABS($tot % 10) * $Multiply) % 10
            
            #Extra rounds
            $InputSignalExtra = $InputSignal * $ExtraInputSignalsAfter
            $PatternIndex = $i
            $tot = 0
            for ($j = 0; $j -lt $InputSignalExtra.Count; $j++) {
                $PatternIndex = ($PatternIndex + 1) % $Pattern.Count
                $tot += $InputSignalExtra[$j] * $Pattern[$PatternIndex]
            }
            $tot = ([Math]::ABS($tot % 10) * $Multiply) % 10
            $result += $tot
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

