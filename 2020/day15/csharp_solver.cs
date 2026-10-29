public static class CalcGame
{
    public static int Run(int[] startNumbers, int target)
    {
        var seenWhen = new int[target];

        for (int turn = 1; turn < startNumbers.Length; turn++)
        {
            seenWhen[startNumbers[turn-1]] = turn;
        }

        int current = startNumbers[startNumbers.Length-1];

        for (var turn = startNumbers.Length; turn < target; turn++)
        {
            int lastSeen = seenWhen[current];
            seenWhen[current] = turn;
            current = lastSeen == 0
                ? 0
                : turn - lastSeen;
        }

        return current;
    }
}