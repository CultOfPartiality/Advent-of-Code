. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"

#The following line is for development
$Path = "$PSScriptRoot/testcases/test1.txt"

function Solution {
	param ($Path)


	$data = get-content $Path

	$bot = [PSCustomObject]@{
		row     = 0
		col     = $data[0].indexof("|")
		dir     = 'd'
		letters = @()
		steps = 0
	}
	function Move-Forward($bot) {
		switch ($bot.dir) {
			'd' { $bot.row++ }
			'u' { $bot.row-- }
			'r' { $bot.col++ }
			'l' { $bot.col-- }
		}
		$bot.steps++
	}
	function Turn-Corner($bot) {
		if ($bot.dir -in ('d', 'u')) {
			$bot.dir = ($data[$bot.row][$bot.col + 1] -ne " ") ? "r" : "l"
		}
		else {
			$bot.dir = ($data[$bot.row + 1][$bot.col] -ne " ") ? "d" : "u"
		}
		Move-Forward($bot)
	}

	:loop while ($true) {
		switch ($data[$bot.row][$bot.col]) {
			{ $_ -in ("|", "-") } {
				Move-Forward($bot)
			}
			"+" {
				Turn-Corner($bot)
			}
			" " {
				break loop
			}
			Default {
				$bot.letters += $_
				Move-Forward($bot)
			}
		}
	}
	$bot.steps
}
Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test1.txt" 38
$measuredTime = measure-command { $result = Solution "$PSScriptRoot\input.txt" }
Write-Host "Part 1: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta

