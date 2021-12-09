defmodule Two do
  def part_one(input) do
    ids = input |> parse() |> Enum.map(&String.graphemes/1)

    count_ids(ids, 2) * count_ids(ids, 3)
  end

  def part_two(input) do
    input
    |> parse()
    |> Stream.map(&String.graphemes/1)
    |> Stream.map(&Enum.with_index/1)
    |> Enum.map(&MapSet.new/1)
    |> solve_two()
  end

  defp parse(text) do
    text
    |> String.trim()
    |> String.split(~r/\R/)
  end

  defp count_ids(ids, n) do
    ids
    |> Enum.map(&Enum.frequencies/1)
    |> Enum.count(fn freqs ->
      freqs
      |> Map.values()
      |> Enum.any?(&(&1 == n))
    end)
  end

  defp solve_two([id | rest]) do
    case Enum.find(rest, &(&1 |> MapSet.difference(id) |> MapSet.size() == 1)) do
      nil -> solve_two(rest)
      x ->
        MapSet.intersection(id, x)
        |> Enum.sort_by(fn {_, i} -> i end)
        |> Enum.map(fn {l, _} -> l end)
        |> Enum.join()
    end
  end
end

input = File.read!("input/02.txt")

input
|> Two.part_one()
|> IO.inspect(label: "part 1")

input
|> Two.part_two()
|> IO.inspect(label: "part 2")
