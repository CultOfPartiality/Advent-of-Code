class Coords {
    $row
    $col
    Coords($row,$col) {
        $this.row = $row
        $this.col = $col
    }
    [string] Hash(){
        return "$($this.row),$($this.col)"
    }
}