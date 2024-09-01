. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"

#The following line is for development
$Path = "$PSScriptRoot/testcases/test1.txt"

function Solution {
	param ($Path)

	$particleNum = 0
	$particles = get-content $Path | % {
		$p, $v, $a = $_ -split ", "
		$p = $p.Substring(3).TrimEnd(">") -split "," | % { [int]$_ }
		$v = $v.Substring(3).TrimEnd(">") -split "," | % { [int]$_ }
		$a = $a.Substring(3).TrimEnd(">") -split "," | % { [int]$_ }
		[PSCustomObject]@{
			num    = $particleNum
			pos    = $p
			vel    = $v
			acc    = $a
			accMag = ($a | % { [math]::Abs($_) } | measure -sum | select -ExpandProperty Sum)
		}
		$particleNum++
	}
	function Sim-Particle($particle) {
		0..2 | % {
			$particle.vel[$_] += $particle.acc[$_]
			$particle.pos[$_] += $particle.vel[$_]
		}
	}

	$particles | sort accMag | select -ExpandProperty num -first 1 

}
Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test1.txt" 0
$measuredTime = measure-command { $result = Solution "$PSScriptRoot\input.txt" }
Write-Host "Part 1: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta

