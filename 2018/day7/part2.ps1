. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"

#The following line is for development
$inputData = @{Path="$PSScriptRoot/testcases/test1.txt"; WorkerCount=2; ExtraDelay=0}

function Solution {
    param ($inputData)

    # Loop over data, building up a graph
    $steps = @{}
    get-content $inputData.Path | % {
        $precursor = $_[5]
        $nextStep = $_[36]
        if (-not($steps.ContainsKey($precursor))) {
            $steps[$precursor] = [PSCustomObject]@{
                Name       = $precursor
                NextSteps  = [System.Collections.ArrayList]@()
                Precursors = [System.Collections.ArrayList]@()
                WorkTime   = ( (1 + [int]$precursor - [int][char]"A") + $inputData.ExtraDelay)
            }
        }
        if (-not($steps.ContainsKey($nextStep))) {
            $steps[$nextStep] = [PSCustomObject]@{
                Name       = $nextStep
                NextSteps  = [System.Collections.ArrayList]@()
                Precursors = [System.Collections.ArrayList]@()
                WorkTime   = ( (1 + [int]$nextStep - [int][char]"A") + $inputData.ExtraDelay)
            }
        }
        $null = $steps[$precursor].NextSteps.Add($steps[$nextStep])
        $null = $steps[$nextStep].Precursors.Add($steps[$precursor])
    }

    $answer = ""
    $stillToGo = $steps.Values
    $workers = 1..$inputData.WorkerCount | %{
        $num = $_
        [PSCustomObject]@{
            Id = $num
            WorkingOn = $null
        }
    }
    $time = 0
    while ( ($stillToGo.Count -gt 0) -or ( ($workers.WorkingOn -ne $null).Count -gt 0) ) {
        $time++
        
        # remove the complete ones (sorted by name) and allocate to a worker if available
        $nextTasks = $stillToGo | ? { $_.precursors.count -eq 0 } | sort Name
        $nextTasks | %{
            $task = $_
            $availableWorkers = $workers | ?{$_.WorkingOn -eq $null}
            if($availableWorkers.count -gt 0){
                $availableWorkers[0].WorkingOn = $task
                $stillToGo = $stillToGo | ? { $_ -ne $task }
            }
        }
        
    
        # Run all workers
        $workers | ?{$_.WorkingOn -ne $null} | sort {$_.WorkingOn.Name} |%{
            $_.WorkingOn.WorkTime--

            # If done, add to answer, then remove from precursors of remaining steps
            if($_.WorkingOn.WorkTime -eq 0){
                $answer += $_.WorkingOn.Name
                for ($i = 0; $i -lt $stillToGo.Count; $i++) {
                    $stillToGo[$i].precursors.Remove($_.WorkingOn)
                }
                $_.WorkingOn = $null
            }
        }
    }
    $time
    
}
Unit-Test  ${function:Solution} @{Path="$PSScriptRoot/testcases/test1.txt"; WorkerCount=2; ExtraDelay=0} 15
$measuredTime = measure-command { $result = Solution @{Path="$PSScriptRoot/input.txt"; WorkerCount=5; ExtraDelay=60} }
Write-Host "Part 2: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta

