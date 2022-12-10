using System.Text;

internal class Program
{
    public static void Main(string[] args)
    {

        // Read input
        List<string> input = File.ReadLines("input").ToList();
        var crateInput = input.TakeWhile(line => line is not "").ToList();
        var operationInput = input.SkipWhile(line => !line.StartsWith("move")).ToList();

        // Parse input
        var crates = ParseCrates(crateInput);
        var operations = ParseOperations(operationInput);

        // Calculate result
        Stack<char>[] result = Array.Empty<Stack<char>>();
        if (args[0] is "a" or "1")
        {
            result = StackMover(crates, operations);
        }
        else if (args[0] is "b" or "2")
        {
            result = StackMover9001(crates, operations);
        }
        else
        {
            Console.WriteLine("Please pick part a (alias 1) or b (alias 2).");
            Environment.Exit(0);
        }

        // Print result
        Console.WriteLine(string.Join("", result.Select(stack => stack.Pop())));
    }

    public static Stack<char>[] StackMover9001(Stack<char>[] crates, IEnumerable<(int, int, int)> operations)
    {
        foreach (var operation in operations)
        {
            List<char> toPush = new();
            for (int i = 0; i < operation.Item1; i++)
            {
                var popped = crates[operation.Item2 - 1].Pop();
                toPush.Add(popped);
            }
            toPush.Reverse();
            foreach (var crate in toPush)
            {
                crates[operation.Item3 - 1].Push(crate);
            }
        }

        return crates;
    }

    public static Stack<char>[] StackMover(Stack<char>[] crates, IEnumerable<(int, int, int)> operations)
    {
        foreach (var operation in operations)
        {
            for (int i = 0; i < operation.Item1; i++)
            {
                var popped = crates[operation.Item2 - 1].Pop();
                crates[operation.Item3 - 1].Push(popped);
            }
        }

        return crates;
    }

    public static IEnumerable<(int, int, int)> ParseOperations(List<string> lines)
    {
        foreach (var line in lines)
        {
            var elements = line.Split();
            yield return (
                int.Parse(elements[1]),
                int.Parse(elements[3]),
                int.Parse(elements[5])
            );
        }
    }

    public static Stack<char>[] ParseCrates(List<string> lines)
    {
        string lastLine = lines.Last();
        List<int> indexes = GetCrateIndexes(lastLine);
        int numStacks = indexes.Count;
        Stack<char>[] crates = new Stack<char>[numStacks];

        for (int x = 0; x < numStacks; ++x)
        {
            crates[x] = new();
            for (int y = lines.Count - 2; y >= 0; --y)
            {
                char box = lines[y][indexes[x]];
                if (box is not ' ')
                {
                    crates[x].Push(box);
                }
            }
        }

        return crates;
    }

    public static List<int> GetCrateIndexes(string line)
    {
        List<int> indexes = new();
        for (int i = 0; i < line.Length; i++)
        {
            if (line[i] is not ' ')
            {
                indexes.Add(i);
            }
        }
        return indexes;
    }

    /// <summary>
    /// Helper method for debugging. Prints a stack array in a readable format.
    /// </summary>
    public static void PrintStackArray<T>(Stack<T>[] stackArray)
    {
        foreach (Stack<T> stack in stackArray)
        {
            Console.WriteLine(string.Join(" ", stack.AsEnumerable()));
        }
    }
}