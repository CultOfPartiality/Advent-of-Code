. "$PSScriptRoot\..\..\Unit-Test.ps1"
. "$PSScriptRoot\..\..\UsefulStuff.ps1"

#The following line is for development
$Path = "$PSScriptRoot/testcases/test2.txt"
$Path = "$PSScriptRoot/input.txt"

function Solution {
    param ($Path)

    $Servers = @{}
    get-content $Path | % {
        $split = $_ -replace ":", "" -split " "
        $Servers[$split[0]] = [PSCustomObject]@{
            Name               = $split[0]
            ConnectionNames    = [array]($split | select -Skip 1)
            ConnectionsTo      = @()
            ConnectedFromNames = @()
            ConnectedFrom      = @()
            JumpsFromDac       = 0
            PathsFromDac = 0
        }
    }
    $Servers["out"] = [PSCustomObject]@{
        Name               = "out"
        ConnectionNames    = @()
        ConnectionsTo      = @()
        ConnectedFromNames = @()
        ConnectedFrom      = @()
    }
    # $graph = ""
    foreach ($server in $Servers.Values) {
        foreach ($ConnectionName in $server.ConnectionNames) {
            $server.ConnectionsTo += $Servers[$ConnectionName]
            $Servers[$ConnectionName].ConnectedFromNames += $server.Name
            $Servers[$ConnectionName].ConnectedFrom += $server
            # $graph += "`t$($server.Name) -> $ConnectionName;`n"
        }
    }

    # "digraph G{
    # `n"+
    # ($graph -join "`n") +
    # "	{}"+
    # "}" | Out-File -FilePath "$PSScriptRoot\vis.dot"

    # dot -Tsvg "$PSScriptRoot\vis.dot" -o "$PSScriptRoot\vis.svg"
    # exit


    # From inspection, the path needs to hit fft first, then dac, then out
    # Looks like there are no loops


    # Actually walk this one in reverse
    $svr_to_fft = 0
    $mostJumps = 10
    $searchSpace = new-object 'System.Collections.Queue'
    $searchSpace.Enqueue(
        [PSCustomObject]@{
            CurrentNode = "fft"
            Jumps       = 0
        })
    while ($searchSpace.Count) {
        $state = $searchSpace.Dequeue()
        foreach ($nextStep in $Servers[$state.CurrentNode].ConnectedFromNames) {
            if ($nextStep -eq "svr") {
                $svr_to_fft++
                continue
            }
            $nextState = [PSCustomObject]@{
                CurrentNode = $nextStep
                Jumps       = $state.Jumps + 1
            }
            if ($nextState.Jumps -ge $mostJumps) { continue }
            $searchSpace.Enqueue($nextState)
        }
    }
    write-host "$svr_to_fft distinct paths between svr and fft"

    # Lower third down to the end
    $dac_to_out = 0
    $searchSpace = new-object 'System.Collections.Queue'
    $searchSpace.Enqueue(
        [PSCustomObject]@{
            CurrentNode = "dac"
            Jumps       = 0
        })
    while ($searchSpace.Count) {
        $state = $searchSpace.Dequeue()
        foreach ($nextStep in $Servers[$state.CurrentNode].ConnectionNames) {
            if ($nextStep -eq "out") {
                $dac_to_out++
                continue
            }
            $nextState = [PSCustomObject]@{
                CurrentNode = $nextStep
                Jumps       = $state.Jumps + 1
            }
            $searchSpace.Enqueue($nextState)
        }
    }
    write-host "$dac_to_out distinct paths between dac and out"

    # And finally the messy middle.........
    # First set the JumpsFromDac for relevant entries
    $mostJumps = 19
    $searchSpace = new-object 'System.Collections.Stack'
    $searchSpace.Push(
        [PSCustomObject]@{
            CurrentNode = "dac"
            Jumps       = 0
        })
    while ($searchSpace.Count) {
        $state = $searchSpace.Pop()
        foreach ($nextStep in $Servers[$state.CurrentNode].ConnectedFromNames) {
            if($Servers[$nextStep].JumpsFromDac -gt $state.Jumps){continue}
            $nextState = [PSCustomObject]@{
                CurrentNode = $nextStep
                Jumps       = $state.Jumps + 1
            }
            $Servers[$nextStep].JumpsFromDac = $nextState.Jumps
            if ($nextState.Jumps -gt $mostJumps) { continue }
            $searchSpace.Push($nextState)
        }
    }


    $fft_to_dac = 0
    $mostJumps = 19
    $searchSpace = new-object 'System.Collections.Queue'
    $searchSpace.Enqueue(
        [PSCustomObject]@{
            CurrentNode = "fft"
            Jumps       = 0
        })
    while ($searchSpace.Count) {
        $state = $searchSpace.Dequeue()
        foreach ($nextStep in $Servers[$state.CurrentNode].ConnectionNames) {
            if ($nextStep -eq "dac") {
                $fft_to_dac++
                continue
            }
            $nextState = [PSCustomObject]@{
                CurrentNode = $nextStep
                Jumps       = $state.Jumps + 1
            }
            if ($nextState.Jumps -gt $mostJumps) { continue }
            $searchSpace.Enqueue($nextState)
        }
    }
    write-host "$fft_to_dac distinct paths between fft and dac"



    $svr_to_fft * $fft_to_dac * $dac_to_out
}
Unit-Test  ${function:Solution} "$PSScriptRoot/testcases/test2.txt" 2
$measuredTime = measure-command { $result = Solution "$PSScriptRoot\input.txt" }
Write-Host "Part 2: $result`nExecution took $($measuredTime.TotalSeconds)s" -ForegroundColor Magenta

#NOT 26