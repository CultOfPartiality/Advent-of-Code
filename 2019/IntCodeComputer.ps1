# For the IntCode computer build up and reused this year
class Computer {
	$memory
	$progPointer = 0
	$complete = $false
	$outputSignal = $null

	Computer($memory) {
		$this.memory = $memory.clone()
	}
	
	# Returns if waiting on input, or if the program has completed. Output is stored internally
	RunComputer($inputSignal) {
		if($this.complete){
			write-host "Error, trying to run a completed computer"
			exit
		}
		$inputCount = 0
		while ($this.memory[$this.progPointer] % 100 -ne 99) {
			$indexes = $this.memory[($this.progPointer + 1)..($this.progPointer + 3)]
			$op = $this.memory[$this.progPointer] % 100

			$param1Mode = [Math]::Floor($this.memory[$this.progPointer] / 100) % 10
			$param2Mode = [Math]::Floor($this.memory[$this.progPointer] / 1000) % 10

			$param1 = $param1Mode ? $indexes[0] : $this.memory[$indexes[0]]
			$param2 = $param2Mode ? $indexes[1] : $this.memory[$indexes[1]]

			if ($op -eq 1) {
				$this.memory[$indexes[2]] = $param1 + $param2
				$this.progPointer += 4
			}
			elseif ($op -eq 2) {
				$this.memory[$indexes[2]] = $param1 * $param2
				$this.progPointer += 4
			}
			elseif ($op -eq 3) {
				#Input
				if($inputCount){
					return #Wait for mor input
				}
				$this.memory[$indexes[0]] = $inputSignal
				$inputCount++
				$this.progPointer += 2
			}
			elseif ($op -eq 4) {
				$this.outputSignal = $param1
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
				$this.memory[$indexes[2]] = [int]($param1 -lt $param2)
				$this.progPointer += 4
			}
			elseif ($op -eq 8) {
				# Equals
				$this.memory[$indexes[2]] = [int]($param1 -eq $param2)
				$this.progPointer += 4
			}
			else {
				write-host "Error, op code $op at index $($this.progPointer) not supported" -ForegroundColor Red
				exit
			}
		}
		$this.complete = $true
	}
}