. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"

#The following line is for development
$string = "{{<!!>},{<!!>},{<!!>},{<!!>}}"

function Solution {
	param ($string)

	$stringCleanedUp = $string -replace "!.", ""
	$originalLen = $stringCleanedUp.Length
	$stringCleanedUp = $stringCleanedUp -replace "<([^>]*)>", "<>"
	$originalLen - $stringCleanedUp.Length
}

Unit-Test  ${function:Solution} "<>" 0
Unit-Test  ${function:Solution} "<random characters>" 17
Unit-Test  ${function:Solution} "<<<<>" 3
Unit-Test  ${function:Solution} "<{!>}>" 2
Unit-Test  ${function:Solution} "<!!>" 0
Unit-Test  ${function:Solution} "<!!!>>" 0
Unit-Test  ${function:Solution} '<{o"i!a,<{i<a>' 10
$measuredTime = measure-command { $result = Solution (get-content "$PSScriptRoot\input.txt") }
Write-Host "Part 2: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta

