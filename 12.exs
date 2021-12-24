defmodule Twelve do
  def part_one(input) do
    input
    |> parse()
    |> then(fn {state, rules} -> run(state, rules, 20) end)
    |> Enum.sum()
  end

  def part_two(input) do
    input
    |> parse()
    |> then(fn {state, rules} ->
      Stream.iterate(100, &(&1 * 10))
      |> Enum.find_value(fn period ->
        r1 = run(state, rules, period)
        r2 = run(r1, rules, period)
        r3 = run(r2, rules, period)
        r4 = run(r3, rules, period)
        interval = Enum.sum(r3) - Enum.sum(r2)

        if (Enum.sum(r4) - Enum.sum(r3)) == interval do
          Enum.sum(r1) + (interval * (div(50_000_000_000, period) - 1))
        else
          false
        end
      end)
    end)
  end

  defp parse(text) do
    text
    |> String.trim()
    |> String.split(~r/\R\R/)
    |> then(fn [a, b] ->
      state =
        a
        |> String.split()
        |> List.last()
        |> String.graphemes()
        |> Enum.with_index()
        |> Enum.reduce(MapSet.new(), fn
          {"#", i}, acc -> MapSet.put(acc, i)
          {".", _}, acc -> acc
        end)
      rules =
        b
        |> String.split(~r/\R|\s=>\s/)
        |> Enum.chunk_every(2)
        |> Enum.reduce(MapSet.new(), fn
          [ins, "#"], acc ->
            ins
            |> String.graphemes()
            |> Enum.map(&(&1 == "#"))
            |> then(&MapSet.put(acc, &1))
          _, acc -> acc
        end)
      {state, rules}
    end)
  end

  defp run(state, _rules, 0), do: state
  defp run(state, rules, n) do
      if rem(n, 100_000) == 0, do: IO.inspect({n, Enum.sum(state)})
    state
    |> step(rules)
    |> run(rules, n - 1)
  end

  defp step(state, rules) do
    {a, b} = Enum.min_max(state)
    (a - 2)..(b + 2)
    |> Enum.reduce(MapSet.new(), fn i, acc ->
      [i - 2, i - 1, i, i + 1, i + 2]
      |> Enum.map(&MapSet.member?(state, &1))
      |> then(fn k ->
        if MapSet.member?(rules, k), do: MapSet.put(acc, i), else: acc
      end)
    end)
  end
end

input = File.read!("input/12.txt")

input |> Twelve.part_one() |> IO.inspect(label: "part 1")
input |> Twelve.part_two() |> IO.inspect(label: "part 2")
