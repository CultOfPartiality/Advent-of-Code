. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"

#The following line is for development
# $Path = "$PSScriptRoot/testcases/test1.txt"
$Path = "$PSScriptRoot/input.txt"

function Solution {
    param ($Path)


    $data = (get-content $Path) -split ',' | % { [int]$_ } 

    $index = 0
    while ($data[$index] % 100 -ne 99) {
        $indexes = $data[($index + 1)..($index + 3)]
        $op = $data[$index] % 100
    
        $param1Mode = [Math]::Floor($data[$index] / 100) % 10
        $param2Mode = [Math]::Floor($data[$index] / 1000) % 10
        $param3Mode = [Math]::Floor($data[$index] / 10000) % 10
    
        $param1 = $param1Mode ? $indexes[0] : $data[$indexes[0]]
        $param2 = $param2Mode ? $indexes[1] : $data[$indexes[1]]
        $param3 = $param3Mode ? $indexes[2] : $data[$indexes[2]]

        if ($op -eq 1) {
            $data[$indexes[2]] = $param1 + $param2
            $index += 4
        }
        elseif ($op -eq 2) {
            $data[$indexes[2]] = $param1 * $param2
            $index += 4
        }
        elseif ($op -eq 3) {
            $data[$indexes[0]] = 1 #Only input gets a 1
            $index += 2   
        }
        elseif ($op -eq 4) {
            if ($data[$index + 2] -eq 99 ) {
                $param1 # output
                return
            }
            elseif ($param1 -ne 0) {
                write-host "Failed at output index $index"
                exit
            }
            $index += 2   
        }
        else {
            write-host "Error, op code $op at index $index not supported" -ForegroundColor Red
            exit
        }
    }


}
# Unit-Test  ${function:Solution} "$PSScriptRoot/../testcases/test1.txt" 3500
$measuredTime = measure-command { $result = Solution "$PSScriptRoot/input.txt" }
Write-Host "Part 1: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta

