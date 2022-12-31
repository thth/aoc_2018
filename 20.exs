defmodule Twenty do
  def part_one(input) do
    input
    |> parse()
    |> paths()
    |> Enum.max_by(&elem(&1, 1))
    |> elem(1)
  end

  def part_two(input) do
    input
    |> parse()
    |> paths()
    |> Enum.count(&(elem(&1, 1) >= 1000))
  end

  defp parse(text) do
    text
    |> String.trim()
  end

  defp paths(str) do
    str
    |> String.graphemes()
    |> Enum.slice(1..-2)
    |> paths([[]], %{})
  end

  defp paths([], _, rooms), do: rooms
  defp paths([c | c_rest], [branch | b_rest], rooms) when c in ~w[N S E W] do
    branches = [branch ++ [c] | b_rest]
    path = branches |> Enum.reverse() |> List.flatten()
    {pos, path_length} = follow_path(path)
    paths(c_rest, branches, Map.update(rooms, pos, path_length, &min(path_length, &1)))
  end
  defp paths(["(" | c_rest], branches, rooms) do
    paths(c_rest, [[] | branches], rooms)
  end
  defp paths(["|" | c_rest], [_ | b_rest], rooms) do
    paths(c_rest, [[] | b_rest], rooms)
  end
  defp paths([")" | c_rest], [_ | b_rest], rooms) do
    paths(c_rest, b_rest, rooms)
  end

  defp follow_path(path, pos \\ {0, 0}, length \\ 0)
  defp follow_path([], pos, length), do: {pos, length}
  defp follow_path(["N" | rest], {x, y}, length), do: follow_path(rest, {x, y - 1}, length + 1)
  defp follow_path(["S" | rest], {x, y}, length), do: follow_path(rest, {x, y + 1}, length + 1)
  defp follow_path(["W" | rest], {x, y}, length), do: follow_path(rest, {x - 1, y}, length + 1)
  defp follow_path(["E" | rest], {x, y}, length), do: follow_path(rest, {x + 1, y}, length + 1)
end

input = File.read!("input/20.txt")

input |> Twenty.part_one() |> IO.inspect(label: "part 1")
input |> Twenty.part_two() |> IO.inspect(label: "part 2")
