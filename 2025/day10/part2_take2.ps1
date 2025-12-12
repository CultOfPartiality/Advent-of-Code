. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"

#The following line is for development
$Path = "$PSScriptRoot/testcases/test1.txt"
$Path = "$PSScriptRoot/input.txt"

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

    # $machines | Foreach-Object -ThrottleLimit 20 -Parallel {
    $result = @()
    $machines | Foreach-Object {

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

            #Fight floating point issues
            for ($col = 0; $col -lt $matrix[0].Count; $col++) {
                for ($row = 0; $row -lt $matrix.Count; $row++) {
                    $val = [Math]::abs( $matrix[$row][$col] )
                    $epsilon = [math]::abs($val - [math]::round($val))
                    if ( $epsilon -lt 1E-5 ) {
                        $matrix[$row][$col] = [Math]::Round($matrix[$row][$col])
                    }
                }
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

            #Fight floating point issues
            for ($i = 0; $i -lt $knownElements.Count; $i++) {
                $val = [Math]::abs( $knownElements[$i] )
                $epsilon = [math]::abs($val - [math]::round($val))
                if ( $epsilon -lt 1E-5 ) {
                    $knownElements[$i] = [Math]::Round($knownElements[$i])
                }
            }

            $valid = ($knownElements -lt 0).count -eq 0
            return @($valid, (($knownElements | measure -Sum).Sum))
        }

        $machine = $_
        # $machine = $machines[0]
        $matrix, $definedElements, $freeElements = GaussJordan-Elimination $machine
        # write-host ("Defined Elements: " + ($definedElements -join ","))
        write-host "Machine {$($machine.Counters -join ",")}"
        $matrix | % { write-host (($_ | % { "$_".PadLeft(3, " ") }) -join ",") }; write-host
        write-host ("Free Elements: " + ($freeElements -join ","))

        #TODO Need to optimise free elements, without another element turning out less than zero
        $knownElements = @($null) * ($matrix[0].Count - 1)
        # $freeElements | % { $knownElements[$_] = 0 }

        $state = [PSCustomObject]@{
            freeElementIndexes = $freeElements
            freeElementValues  = @(0) * $freeElements.Count
            total              = [int32]::MaxValue
            valid              = $false
            prevValid          = $false
            prevTotal          = [int32]::MaxValue
        }
        $knownElements = @($null) * ($matrix[0].Count - 1)
        if ($state.freeElementIndexes.Count) {
            0..($state.freeElementIndexes.count - 1) | % {
                $index = $state.freeElementIndexes[$_]
                $knownElements[$index] = $state.freeElementValues[$_]
            }
        }
        $state.valid, $state.total = Sum-Matrix -matrixInput $matrix -knownElements $knownElements
    
        $statesSeen = @{}
        $searchSpace = New-Object 'System.Collections.Generic.PriorityQueue[psobject,int]'
        if ($state.freeElementIndexes.Count) {
            # Don't populate if we've got no free elements; we're done
            $searchSpace.Enqueue($state, 0)
            $minPushes = ($state.valid -and $state.total -eq [Math]::floor($state.total) )? $state.total : [int32]::MaxValue
            $anyValidOptionFound = ($state.valid -and $state.total -eq [Math]::floor($state.total) )
        }
        else {
            $minPushes = $state.total
        }
        $statesSeen[$state.freeElementValues -join ","] = 1
        write-host "`tStarting total: $minPushes"
    
        while ($searchSpace.Count) {
            $state = $searchSpace.Dequeue()
            for ($freeIndex = 0; $freeIndex -lt $state.freeElementIndexes.Count; $freeIndex++) {
                $newState = [PSCustomObject]@{
                    freeElementIndexes = $state.freeElementIndexes.clone()
                    freeElementValues  = $state.freeElementValues.clone()
                    total              = $null
                    valid              = $null
                    prevValid          = $state.valid
                    prevTotal          = $state.total
                }
                $newState.freeElementValues[$freeIndex]++
                if ($statesSeen.ContainsKey($newState.freeElementValues -join ",")) { continue }
                $statesSeen[$newState.freeElementValues -join ","] = 1
                $knownElements = @($null) * ($matrix[0].Count - 1)
                0..($newState.freeElementIndexes.count - 1) | % {
                    $index = $newState.freeElementIndexes[$_]
                    $knownElements[$index] = $newState.freeElementValues[$_]
                }
                $newState.valid, $newState.total = Sum-Matrix -matrixInput $matrix -knownElements $knownElements
                # write-host "Button pushes: ($($knownElements -join ",")) = $total"

                $priority = ( $newState.valid ? [math]::Abs($newState.total) : ($knownElements | ? { $_ -lt 0 } | % { - $_ } | sum-array ) )
                # if no valid options have been found, keep going
                if (!$anyValidOptionFound) {
                    $searchSpace.Enqueue($newState, $priority)
                }
                # if fractional, the total's still valid, keep going
                if(  $newState.total -ne [Math]::Floor($newState.total) -and $newState.valid ){
                    $searchSpace.Enqueue($newState, $priority)
                }
                # if previously valid and now not valid, don't go again
                # if previously not valid and now valid, store and go again
                elseif (!$newState.prevValid -and $newState.valid) {
                    $searchSpace.Enqueue($newState, $priority)
                }
                # if previously valid and still valid, and the total has gone down or is the same, store and go again
                elseif (
                    # $newState.prevValid -and
                    # $newState.valid -and
                    ($newState.prevValid -or $newState.valid) -and
                    ($newState.total -le ($newState.prevTotal + 5) <#-or $newstate.total -le ($minPushes + 20)#>)
                    ) {
                    $searchSpace.Enqueue($newState, $priority)
                }
                elseif(($knownElements| Measure-Object -Minimum).Minimum -gt -50 -and $newstate.total -le ($minPushes + 20)){
                    $searchSpace.Enqueue($newState, $priority)
                }

                $anyValidOptionFound = $anyValidOptionFound -or ($newState.valid -and $newState.total -eq [Math]::Floor($newState.total))

                if ($newstate.valid -and
                    $newState.total -lt $minPushes -and
                    $newState.total -eq [Math]::Floor($newState.total) ) {
                    $minPushes = $newState.total
                    write-host "`tNew min total: $minPushes"
                }
            }
        }
        write-host "`t`tFinal min total: $minPushes"

        if (($minPushes -ne [math]::floor($minPushes))) {
            write-host "Error, result is a fractional button press..."  -ForegroundColor Red
            exit
        }
        if ($minPushes -eq [int32]::MaxValue) {
            write-host "Error, valid solution not found..." -ForegroundColor Red
            exit
        }
    
        $result += $minPushes
    }
    $result | sum-array
}
Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test1.txt" 33
$measuredTime = measure-command { $result = Solution "$PSScriptRoot\input.txt" }
Write-Host "Part 2: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta
if($result -ge 16385){write-host "$result is too high" -ForegroundColor Red}
write-host "Not 16366 or 16359" -ForegroundColor Yellow