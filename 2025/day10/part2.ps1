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
    foreach($machine in $machines) {
		# $machine = $_

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
			# [array]::reverse($matrix) # Does this affect anything? No
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

        $matrix, $definedElements, $freeElements = GaussJordan-Elimination $machine
		write-host "----------------------------------------"
        write-host "Machine {$($machine.Counters -join ",")}"
        $matrix | % { write-host (($_ | % { "$_".PadLeft(3, " ") }) -join ",") }; write-host
        # write-host ("Free Elements: " + ($freeElements -join ","))
		
		if($freeElements.Count -eq 0){
			$valid,$total = Sum-Matrix -matrixInput $matrix -knownElements (@($null) * ($matrix[0].Count - 1))
			write-host "`tNo free elements, so can just do summation: $total" -ForegroundColor DarkGreen
			$result += $total
			if(!$valid){
				write-host "`thuh, not valid?" -ForegroundColor Red
				exit
			}
			continue
		}
		
		# Need to work out limits for free elements... Start with 0 to all the presses
		$maxPresses = ($machine.Counters | measure -Maximum).Maximum
		$freeElementInfos = $freeElements | %{
			[PSCustomObject]@{
				index = $_
				min = 0
				max = $maxPresses
			}
		}
		$freeElementEquations = $matrix | %{
			$row = $_
			if( ($freeElements | %{$row[$_]}) -ne 0){
				,$row
			}
		}

		0..20 | %{
			$equationIndex = ($equationIndex+1) % $freeElementEquations.Count
			$equation = $freeElementEquations[$equationIndex]
			
			foreach($freeElementInfo in ($freeElementInfos | ?{$equation[$_.index] -ne 0})){
				$biggestSum = $equation[-1]
				$smallestSum = $equation[-1]
				#Worst case
				foreach($otherFreeElementInfo in ($freeElementInfos | ?{$_.index -ne $freeElementInfo.index})){
					if($equation[$otherFreeElementInfo.index] -gt 0){
						$biggestSum -= $equation[$otherFreeElementInfo.index] * $otherFreeElementInfo.min
						$smallestSum -= $equation[$otherFreeElementInfo.index] * $otherFreeElementInfo.max
					}
					else{
						$biggestSum -= $equation[$otherFreeElementInfo.index] * $otherFreeElementInfo.max
						$smallestSum -= $equation[$otherFreeElementInfo.index] * $otherFreeElementInfo.min
					}
				}
				if($equation[$freeElementInfo.index] -gt 0 -and $biggestSum -gt 0){ #subtracted from sum
					$freeElementInfo.max = [Math]::Min([math]::Ceiling( ($biggestSum)/$equation[$freeElementInfo.index] ),$freeElementInfo.max)
				}
				elseif($equation[$freeElementInfo.index] -lt 0 -and $biggestSum -lt 0){
					$freeElementInfo.min = [Math]::Max([math]::Floor((-$smallestSum)/$equation[$freeElementInfo.index]),$freeElementInfo.min)
				}
			}
		}
		write-host "Free Elements:"
		foreach($freeElementInfo in $freeElementInfos){
			write-host "`tIndex $($freeElementInfo.index): [$($freeElementInfo.min),$($freeElementInfo.max)]"
		}
		

		$bestTotal = [int32]::MaxValue
		for ($i = $freeElementInfos[0].min; $i -le $freeElementInfos[0].max; $i++) {
			for ($j = $freeElementInfos[1].min; $j -le $freeElementInfos[1].max; $j++) {
				for ($k = $freeElementInfos[2].min; $k -le $freeElementInfos[2].max; $k++) {
					$knownElements = @($null) * ($matrix[0].Count - 1)
					$knownElements[$freeElementInfos[0].index] = $i
					if($freeElementInfos[1]){$knownElements[$freeElementInfos[1].index] = $j}
					if($freeElementInfos[2]){$knownElements[$freeElementInfos[2].index] = $k}
					$valid, $total = Sum-Matrix -matrixInput $matrix -knownElements $knownElements
					$allRowsInts = ($knownElements | ?{$_ -ne [Math]::Round($_)}).count -eq 0
					if($valid -and $total -lt $bestTotal -and $total -eq [Math]::Round($total)){
						if(!$allRowsInts){
							write-host "For total $total, a row is not an int!!" -ForegroundColor Blue
						}
						else{	
							write-host "New best total $total"
							$bestTotal = $total
						}
					}
				}
			}
		}
		if($bestTotal -eq [int32]::MaxValue){
			write-host "Error" -ForegroundColor Red
			exit
		}
		$result += $bestTotal
        
    }
	$result | sum-array
}
Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test1.txt" 33
$measuredTime = measure-command { $result = Solution "$PSScriptRoot\input.txt" }
Write-Host "Part 2: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta