. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"

#The following line is for development
$Path = "$PSScriptRoot/testcases/test1.txt"

function Solution {
	param ($Path)

	$data = get-content $Path

	# --- The Plan ---
	# Do we have to handle an arbitary board size? Or can we get away with just a 'big' board?
	# No idiot, just keep a hashmap of all locations seen thus far, and track the location of the virus
	$startIndex = ($data.count - 1) / 2
	$virus = [PSCustomObject]@{
		dir = 0
		x   = $startIndex
		y   = $startIndex
	}
	enum State {
		Cleaned
		Weakened
		Infected
		Flagged
	}

	$map = @{}
	for ($y = 0; $y -lt $data.Count; $y++) {
		for ($x = 0; $x -lt $data.Count; $x++) {
			$map["$x,$y"] = $data[$y][$x] -eq "#" ? [State]::Infected : [State]::Cleaned
		}
	}

	$infections = 0
	for ($i = 0; $i -lt 10000000; $i++) {
		$nodeState = $map["$($virus.x),$($virus.y)"] ?? [State]::Cleaned
		# Step 1: Change direction
		# Step 2: Change node state (and count new infections)
		switch ($nodeState) {
		([state]::Cleaned) { $nodeState++; $virus.dir -= 1 }
		([state]::Weakened) { $nodeState++; $infections++ }
		([state]::Infected) { $nodeState++; $virus.dir += 1 }
		([state]::Flagged) { $nodeState = [state]::Cleaned; $virus.dir += 2 }
			Default { write-host "Error"; exit }
		}
		$virus.dir = ($virus.dir + 4) % 4
		$map["$($virus.x),$($virus.y)"] = $nodeState
		# Step 3: Move virus
		switch ($virus.dir) {
			0 { $virus.y-- }
			1 { $virus.x++ }
			2 { $virus.y++ }
			3 { $virus.x-- }
		}
	}
	$infections

}
Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test1.txt" 2511944
$measuredTime = measure-command { $result = Solution "$PSScriptRoot\input.txt" }
Write-Host "Part 2: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta

