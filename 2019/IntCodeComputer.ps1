# For the IntCode computer build up and reused this year
class Computer {
	$memory = [int64[]]::New(20000)
	$progPointer = 0
	$relativeBase = 0
	$complete = $false
	$outputSignal = $null
	$outputBuffer = @()

	Computer($memory) {
		for ($i = 0; $i -lt $memory.Count; $i++) {
			$this.memory[$i] = [int64]$memory[$i]
		}
	}
	
	# Returns if waiting on input, or if the program has completed. Output is stored internally
	RunComputer($inputSignal) {
		if ($this.complete) {
			write-host "Error, trying to run a completed computer"
			exit
		}
		$inputCount = $inputSignal -eq $null ? 1 : 0
		while ($this.memory[$this.progPointer] % 100 -ne 99) {
			$indexes = $this.memory[($this.progPointer + 1)..($this.progPointer + 3)]
			$op = $this.memory[$this.progPointer] % 100

			$param1Mode = [Math]::Floor($this.memory[$this.progPointer] / 100) % 10
			$param2Mode = [Math]::Floor($this.memory[$this.progPointer] / 1000) % 10
			$param3Mode = [Math]::Floor($this.memory[$this.progPointer] / 10000) % 10

			$param1 = switch ($param1Mode) {
				0 { $this.memory[$indexes[0]] }
				1 { $indexes[0] }
				2 { $this.memory[$indexes[0] + $this.relativeBase] }
			}
			$param2 = switch ($param2Mode) {
				0 { $this.memory[$indexes[1]] }
				1 { $indexes[1] }
				2 { $this.memory[$indexes[1] + $this.relativeBase] }
			}
			$param3 = switch ($param3Mode) {
				0 { $indexes[2] }
				1 { $indexes[2] }
				2 { $indexes[2] + $this.relativeBase }
			}
			

			if ($op -eq 1) {
				$this.memory[$param3] = $param1 + $param2
				$this.progPointer += 4
			}
			elseif ($op -eq 2) {
				$this.memory[$param3] = $param1 * $param2
				$this.progPointer += 4
			}
			elseif ($op -eq 3) {
				#Input
				$param1 = switch ($param1Mode) {
					0 { $indexes[0] }
					1 { $indexes[0] }
					2 { $indexes[0] + $this.relativeBase }
				}
				if ($inputCount) {
					return #Wait for mor input
				}
				$this.memory[$param1] = $inputSignal
				$inputCount++
				$this.progPointer += 2
			}
			elseif ($op -eq 4) {
				$this.outputSignal = $param1
				$this.outputBuffer += $param1
				$this.progPointer += 2   
			}
			elseif ($op -eq 5) {
				#Jump if true
				$this.progPointer += 3
				if ($param1 -ne 0) {
					$this.progPointer = $param2
				}
			}
			elseif ($op -eq 6) {
				#Jump if false
				$this.progPointer += 3
				if ($param1 -eq 0) {
					$this.progPointer = $param2
				}
			}
			elseif ($op -eq 7) {
				# Less than
				$this.memory[$param3] = [int]($param1 -lt $param2)
				$this.progPointer += 4
			}
			elseif ($op -eq 8) {
				# Equals
				$this.memory[$param3] = [int]($param1 -eq $param2)
				$this.progPointer += 4
			}
			elseif ($op -eq 9) {
				# Adjust relative base
				$this.relativeBase += $param1
				$this.progPointer += 2
			}
			else {
				write-host "Error, op code $op at index $($this.progPointer) not supported" -ForegroundColor Red
				exit
			}
		}
		$this.complete = $true
	}
}