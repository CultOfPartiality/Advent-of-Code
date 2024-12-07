. "$PSScriptRoot\..\..\Unit-Test.ps1"

#The following line is for development
$Path = "$PSScriptRoot/testcases/test1.txt"

function Solution {
	param ($Path)

	# For each line, work out how many permutations of +'s, *'s, and ||'s there are. Each permuation encodes the operations
	# to execute in trinary, where a 0 trit is +, a 1 trit is *, and a 2 trit is concat. Run each until we find a perm that works, 
	# then add that total to the calibartion value.

	# Parallelisation here is pretty good, since checking each line against all perms can take some work
	# Without "-Parallel" it takes longer than at least 5 minutes (I got bored waiting)


	# Split input up into 16 chucks, one for each thread, so we get the maximum bang for our buck with parallelisation
	# Or at least so you'd think... not actually better than otherwise
	$data = get-content $Path
	$threadLimit = [math]::Min(16, $data.count)
	write-host "Threads: $threadLimit"

	$dataChucks = for ($i = 0; $i -lt $threadLimit; $i++) {
		$min = $i * [math]::Ceiling($data.count / $threadLimit)
		$max = [math]::Min( ($i + 1) * [math]::Ceiling($data.count / 16), $data.count ) - 1
		, @($data[$min..$max])
	}

	$dataChucks | Foreach-Object -ThrottleLimit $threadLimit -Parallel {
		$thread = [System.Threading.Thread]::CurrentThread
		$thread.Priority = "Highest"

		$_ | ForEach-Object {
			$line = $_
			[int64]$total, [int64[]]$values = ($line -replace ":", "" -split " ")

			# The concat only will alway be the biggest, but usually this is too big, and we already know from
			# part 1 that just multiplying the entries can get us valid totals
			$min = 0
			$max = 1
			$concatMax = [int64]($values -join "")
			foreach ($value in ($values -ne 1)) {
				$min += $value
				$max *= $value
			}
			# Exit early if the min or max value was already valid, or the total would be out of reach
			if ($total -in $min, $max, $concatMax) {
				$total
				return
			}
			#This removes 3 entries from the calc....
			if ($concatMax -lt $total -or $min -gt $total) {
				return
			}
	
			$perms = [math]::pow(3, $values.Count - 1)
			:permLoop for ($currentPerm = 0; $currentPerm -lt $perms; $currentPerm++) {
				#
				$currentTotal = $values[0]
				for ($opPos = 0; $opPos -lt ($values.Count - 1); $opPos++) {
					$opNum = [math]::Floor($currentPerm / [math]::pow(3, $opPos)) % 3
					switch ($opnum) {
						2 { $currentTotal += $values[$opPos + 1] }
						1 { $currentTotal *= $values[$opPos + 1] }
						0 { $currentTotal = [int64]("$currentTotal" + "$($values[$opPos + 1])") }
					}
					if ($currentTotal -gt $total) { continue permLoop }
				}
				if ($currentTotal -eq $total) {
					$total
					break permLoop
				}
			}
		} | measure -sum | select -ExpandProperty Sum
	} | measure -sum | select -ExpandProperty Sum
    
}
Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test1.txt" 11387
$measuredTime = measure-command { $result = Solution "$PSScriptRoot\input.txt" }
Write-Host "Part 2: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta

