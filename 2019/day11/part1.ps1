. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"

# Reused IntCode computer this year
. "$PSScriptRoot\..\IntCodeComputer.ps1"

#The following line is for development
$Path = "$PSScriptRoot/input.txt"

function Solution {
	param ($Path)

	$memory = (get-content $Path) -split ',' | % { [int64]$_ } 

	$BLACK = 0
	$WHITE = 1
	$grid = @{}

	enum Direction{
		Up = 0
		Right = 1
		Down = 2
		Left = 3
	}
	$Robot = [PSCustomObject]@{
		Brain     = [Computer]::New($memory)
		Direction = [Direction]::Up
		y         = 0
		x         = 0
	}

	$painted = @{}
	do {
		$hash = "$($Robot.y),$($Robot.x)"
		$currentPanel = $grid[$hash] ?? $BLACK
		$Robot.Brain.RunComputer($currentPanel)
	
		$grid[$hash] = $Robot.Brain.outputBuffer[0]
		if ($Robot.Brain.outputBuffer[0]) {
			$painted[$hash] = 1
		}
		$Robot.Direction = ($Robot.Direction + 4 + ($Robot.Brain.outputBuffer[1] ? 1 : -1) ) % 4
		switch ( ([Direction]$Robot.Direction) ) {
			([Direction]::Up) { $Robot.y++ }
			([Direction]::Down) { $Robot.y-- }
			([Direction]::Left) { $Robot.x-- }
			([Direction]::Right) { $Robot.x++ }
		}
		$Robot.Brain.outputBuffer = @()
	}while (!$Robot.Brain.complete)
	$painted.count

}
$measuredTime = measure-command { $result = Solution "$PSScriptRoot\input.txt" } #2720
Write-Host "Part 1: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta

