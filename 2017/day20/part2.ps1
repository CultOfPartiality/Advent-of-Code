. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"

#The following line is for development
$Path = "$PSScriptRoot/testcases/test2.txt"
$Path = "$PSScriptRoot/input.txt"

# function Solution {
# 	param ($Path)

$particleNum = 0
$particles = get-content $Path | % {
	$p, $v, $a = $_ -split ", "
	$p = $p.Substring(3).TrimEnd(">") -split "," | % { [int]$_ }
	$v = $v.Substring(3).TrimEnd(">") -split "," | % { [int]$_ }
	$a = $a.Substring(3).TrimEnd(">") -split "," | % { [int]$_ }
	[PSCustomObject]@{
		num                     = $particleNum
		pos                     = $p
		prevPos                 = $null
		vel                     = $v
		acc                     = $a
		countOfClosingParticles = 0
	}
	$particleNum++
}
function Sim-Particle($particle) {
	$particle.prevPos = $particle.pos.clone()
	0..2 | % {
		$particle.vel[$_] += $particle.acc[$_]
		$particle.pos[$_] += $particle.vel[$_]
	}
}
function Calc-Distance {
	param($p1, $p2)
	0..2 | % { [math]::abs($p1[$_] - $p2[$_]) } | measure -sum | select -ExpandProperty Sum
}
function Is-Accelerating($particle){
	[math]::sign($particle.vel[0]) -eq [math]::sign($particle.acc[0]) -and
	[math]::sign($particle.vel[1]) -eq [math]::sign($particle.acc[1]) -and
	[math]::sign($particle.vel[2]) -eq [math]::sign($particle.acc[2])
}

# One round of simulation to get "prev positions"
$particles | % { Sim-Particle($_) }
$particles = $particles | group { $_.pos -join "," } | ? { $_.Count -eq 1 } | select -ExpandProperty Group

while ($true) {
	# Work out if any particles are travelling towards each other:
	# 	If the new distance between particles is smaller than the previous distance between particles
	#$particles = $particles | group { $_.pos -join "," } | ? { $_.Count -eq 1 } | select -ExpandProperty Group

	# Searching for pairs travelling closer to eachother is somewhat optimises, but towards the end we're having to check the whole crossjoin which is stopping it from completing
	# Further more, some are still "travelling towards each other" but actually won't collide. We need to work this out, so we can only do a single cross join
	# We also need to not do a full crossjoin, but a reducing one....
	$anyTravellingTowardEachother = $false
	for ($i = 0; $i -lt ($particles.Count-1); $i++) {
		$particle = $particles[$i]
		for ($j = $i+1; $j -lt $particles.Count; $j++) {
			$otherParticle = $particles[$j]
			# If both have stopped deccelerating, then check that one at least on axis isn't the same and isn't getting closer
			if( Is-Accelerating($particle) -and Is-Accelerating($otherParticle)){
				$deltaDist = 0..2 | %{ [math]::abs($particle.pos[$_]-$otherParticle.pos[$_]) - [math]::abs($particle.prevPos[$_]-$otherParticle.prevPos[$_]) }
				if($deltaDist -ge 0){
					#one axis isn't getting close, continue
					continue
				}
			}
			# Else, just check the overall distance
			$deltaDistance = (Calc-Distance $particle.pos $otherParticle.pos) - (Calc-Distance $particle.prevPos $otherParticle.prevPos)
			if($deltaDistance -lt 0){
				$particle.countOfClosingParticles = 1
				$otherParticle.countOfClosingParticles = 1
				write-host "Particle $($particle.num) and $($otherparticle.num) are getting closer. DeltaDist: $($deltaDist -join ", ")" -ForegroundColor DarkGray
				break
			}
		}

		if ($particle.countOfClosingParticles -gt 0) {
			$anyTravellingTowardEachother = $true
			break
		}
	}
	if (-not $anyTravellingTowardEachother) {
		break
	}
	$particles = $particles | sort -Property countOfClosingParticles -Descending
	$particles[0].countOfClosingParticles = 0
	$particles[1].countOfClosingParticles = 0
	$particles | % { Sim-Particle($_) }
	$particles = $particles | group { $_.pos -join "," } | ? { $_.Count -eq 1 } | select -ExpandProperty Group
	if($particles.count -ne $prevParticleCount){
		write-host "Down to $($particles.Count) particles..."
	}
	$prevParticleCount = $particles.count

}
# }
# Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test1.txt" 1
# $measuredTime = measure-command { $result = Solution "$PSScriptRoot\input.txt" }
# Write-Host "Part 2: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta

