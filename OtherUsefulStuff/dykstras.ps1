# Need to implement a general dykstras to be able to reuse

# Each node in the graph needs at minimum:
#   dist - Start at a verybig number
#   prev - $null
#   links - Array of neighbour objects

function dikstras($graph, $startNode) {

    $q = New-Object "System.Collections.Generic.PriorityQueue[psobject,int]"

    $startNode.dist = 0
    $q.Enqueue($startNode, 0)

    while ($q.Count) {
        $u = $q.Dequeue()
        foreach ($v in $u.links) {
            $alt = $u.dist + 1
            if ($v.prev -eq $null -or $alt -lt $v.dist) {
                $v.prev = $u
                $v.dist = $alt
                $q.Enqueue($v, $v.dist) 
            }
        }
    }
}

# $graph = @()

# $graph += [pscustomobject]@{
#     name  = "1"
#     links = @()
#     dist  = [int32]::MaxValue
#     prev  = $null
# }
# $graph += [pscustomobject]@{
#     name  = "2"
#     links = @()
#     dist  = [int32]::MaxValue
#     prev  = $null
# }
# $graph += [pscustomobject]@{
#     name  = "3"
#     links = @()
#     dist  = [int32]::MaxValue
#     prev  = $null
# }
# $graph += [pscustomobject]@{
#     name  = "4"
#     links = @()
#     dist  = [int32]::MaxValue
#     prev  = $null
# }

# $graph[0].links += $graph[1]
# $graph[0].links += $graph[2]
# $graph[1].links += $graph[3]

# dikstras $graph $graph[0]
