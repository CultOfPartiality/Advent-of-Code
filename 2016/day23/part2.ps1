. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"

#The following line is for development
$Path = "$PSScriptRoot/input.txt"

#Machine simplifies to a! + 85*92
$result = 1
1..12 | %{ $result*=$_ }
$result + 85*92

# }
# Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test1.txt" 42
# $measuredTime = measure-command { $result = Solution "$PSScriptRoot\input.txt" }
# Write-Host "Part 1: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta

