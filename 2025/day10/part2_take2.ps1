. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"

#The following line is for development
$Path = "$PSScriptRoot/testcases/test1.txt"

function Solution {
    param ($Path)

    $machines = get-content $Path | % {
        $blocks = $_ -split " "
        $Buttons = $blocks[1..($blocks.Count - 2)] | % {
            , ($_ -replace "[\(\)]", "" -split "," | % { [int]$_ })
        }
        $Joltages = $blocks[-1] -replace "[\{\}]", "" -split "," | % { [int]$_ }
        [PSCustomObject]@{
            Counters = $Joltages
            Buttons  = $Buttons
        }
    }

    $machines | Foreach-Object -ThrottleLimit 20 -Parallel {
        # $machines | Foreach-Object {

        function GaussJordan-Elimination {
            param ($machine)
    

            #### Gauss-Jordan Elimination
            # Build Matrix
            $row = @(0) * ($machine.Buttons.Count + 1)
            $matrix = 1..$machine.Counters.Count | % { , $row.Clone() }
            for ($i = 0; $i -lt $machine.Counters.Count; $i++) {
                $matrix[$i][-1] = $machine.Counters[$i]
            }
            for ($i = 0; $i -lt $machine.Buttons.Count; $i++) {
                $Button = $machine.Buttons[$i]
                for ($j = 0; $j -lt $machine.Counters.Count; $j++) {
                    if ($Button -contains $j) {
                        $matrix[$j][$i] = 1
                    }
                }
            }

            # #Debug
            # write-host "Initial matrix:"
            # $matrix | % { write-host ($_ -join ",") }
            # write-host


            $row = 0
            for ($col = 0; $col -lt $matrix[0].Count - 1; $col++) {
                if ($row -ge $matrix.count) { break }
                $nonZerosInCol = $row..($matrix.count - 1) | ? { $matrix[$_][$col] -ne 0 }
                if ($nonZerosInCol.count -eq 0) { continue }
                if ($matrix[$row][$col] -eq 0) {
                    $matrix[$row], $matrix[$nonZerosInCol[0]] = $matrix[$nonZerosInCol[0]], $matrix[$row]
                }
                if ($matrix[$row][$col] -ne 1) {
                    $divisor = $matrix[$row][$col]
                    for ($col2 = $col; $col2 -lt $matrix[0].Count; $col2++) {
                        $matrix[$row][$col2] /= $divisor
                    }
                }
                for ($i = 0; $i -lt $matrix.Count; $i++) {
                    if ($i -eq $row) { continue }
                    if ($matrix[$i][$col] -ne 0) {
                        $multiple = $matrix[$i][$col]
                        for ($col2 = $col; $col2 -lt $matrix[0].Count; $col2++) {
                            $matrix[$i][$col2] -= ($matrix[$row][$col2] * $multiple)
                        }
                    }
                }
                $row++
                # #Debug
                # write-host "Round $col"
                # $matrix | %{ write-host ($_ -join ",") }
                # write-host
            }

            # #Debug
            # write-host "Reduced matrix:"
            # $matrix | % { write-host ($_ -join ",") }
            # write-host


            #Elements that are used are rows with a 1 in that place at the start
            #The others are "free"
            $definedElements = 0..($matrix.count - 1) | % {
                $rowIndex = $_
                0..($matrix[0].count - 2) | ? { $matrix[$rowIndex][$_] -eq 1 } | select -first 1
            }
            [array]$freeElements = 0..($matrix[0].count - 2) | ? { $_ -notin $definedElements }

            @($matrix, $definedElements, $freeElements)
        }


        function Sum-Matrix {
            param($matrixInput, $knownElements)
            $matrix = foreach ($row in $matrixInput) {
                , $row.Clone()
            }

            #Rescale columns using "free" elements
            0..($matrix[0].count - 2) | ? { $knownElements[$_] -ne $null } | % {
                $col = $_
                foreach ($row in $matrix) {
                    $row[$col] *= $knownElements[$col]
                }
            }

            #Perform the summation
            foreach ($row in $matrix) {
                $index = 0..($matrix[0].count - 2) | ? { $row[$_] -eq 1 } | select -first 1
                if ($index -eq $null) { continue }
                $otherIndexes = $index -lt $matrix[0].count - 2 ? ($index + 1)..($matrix[0].count - 2) : $null

                $knownElements[$index] = $row[-1]
                foreach ($i in $otherIndexes) { $knownElements[$index] -= $row[$i] }
            }
            $valid = ($knownElements -lt 0).count -eq 0
            return @($valid, (($knownElements | measure -Sum).Sum))
        }

        $machine = $_
        # $machine = $machines[0]
        $matrix, $definedElements, $freeElements = GaussJordan-Elimination $machine
        # write-host ("Defined Elements: " + ($definedElements -join ","))
        # write-host ("Free Elements: " + ($freeElements -join ","))

        #TODO Need to optimise free elements, without another element turning out less than zero
        $knownElements = @($null) * ($matrix[0].Count - 1)
        # $freeElements | % { $knownElements[$_] = 0 }

        $fewestPresses = [int32]::MaxValue
        for ($i = 0; $i -le ($freeElements.Count -gt 0 ? 150 : 0); $i++) {
            for ($j = 0; $j -le ($freeElements.Count -gt 1 ? 80 : 0); $j++) {
                for ($k = 0; $k -le ($freeElements.Count -gt 2 ? 60 : 0); $k++) {
                    $options = $i, $j, $k
                    $knownElements = @($null) * ($matrix[0].Count - 1)
                    if ($freeElements.Count) {
                        0..($freeElements.Count - 1) | % { $knownElements[$freeElements[$_]] = $options[$_] }
                    }
                    $valid, $total = Sum-Matrix -matrixInput $matrix -knownElements $knownElements
                    if ($valid) {
                        $fewestPresses = [Math]::Min($fewestPresses, $total)
                    }
                }
            }
        }
        if ($fewestPresses -eq [int32]::MaxValue) {
            write-host ("Error, need more checks. Free Elements: " + ($freeElements -join ","))
            exit
        }

        # $valid, $total = Sum-Matrix -matrixInput $matrix -knownElements $knownElements
        # if (!$valid) {
        #     write-host "Error"
        #     exit
        # }
        # $state = [PSCustomObject]@{
        #     freeElementIndexes = $freeElements
        #     freeElementValues  = @(0) * $freeElements.Count
        #     total              = $total
        # }
        #
        # $searchSpace = New-Object 'System.Collections.Stack'
        # $searchSpace.Push($state)
        # $minPushes = $state.total
        #
        # while ($searchSpace.Count) {
        #     $state = $searchSpace.Pop()
        #     for ($freeIndex = 0; $freeIndex -lt $state.freeElementIndexes.Count; $freeIndex++) {
        #         $newState = [PSCustomObject]@{
        #             freeElementIndexes = $state.freeElementIndexes.clone()
        #             freeElementValues  = $state.freeElementValues.clone()
        #             total              = $null
        #         }
        #         $newState.freeElementValues[$freeIndex]++
        #         $knownElements = @($null) * ($matrix[0].Count - 1)
        #         0..($newState.freeElementIndexes.count - 1) | % {
        #             $index = $newState.freeElementIndexes[$_]
        #             $value = $newState.freeElementValues[$_]
        #             $knownElements[$index] = $value
        #         }
        #         $valid, $newState.total = Sum-Matrix -matrixInput $matrix -knownElements $knownElements
        #         # write-host "Button pushes: ($($knownElements -join ",")) = $total"
        #         if ($valid -and $newState.total -le $minPushes) {
        #             $minPushes = $newState.total
        #             write-host "`tNew min total: $minPushes"
        #             $searchSpace.Push($newState)
        #         }
        #     }
        # }
        # write-host "`t`tFinal min total: $minPushes"
    
        $fewestPresses
    } | sum-array
}
Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test1.txt" 33
$measuredTime = measure-command { $result = Solution "$PSScriptRoot\input.txt" }
Write-Host "Part 2: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta
write-host "55834588098 is too high" -ForegroundColor Yellow