defmodule Eighteen do
  def part_one(input) do
    input
    |> parse()
    |> Stream.iterate(&step/1)
    |> Enum.at(10)
    |> resource_value()
  end

  def part_two(input) do
    input
    |> parse()
    |> Stream.iterate(&step/1)
    |> Stream.with_index()
    |> Enum.reduce_while(%{}, fn {map, i}, acc ->
      if Map.has_key?(acc, map), do: {:halt, {map, acc[map], i}}, else: {:cont, Map.put(acc, map, i)}
    end)
    |> then(fn {map, a, b} ->
      Stream.iterate(map, &step/1)
      |> Enum.at(rem(1_000_000_000 - a, b - a))
      |> resource_value()
    end)
  end

  defp parse(text) do
    text
    |> String.trim()
    |> String.split(~r/\R/)
    |> Enum.with_index()
    |> Enum.reduce(%{}, fn {row, y}, acc ->
      row
      |> String.graphemes()
      |> Enum.with_index()
      |> Enum.reduce(acc, fn {c, x}, row_acc ->
        Map.put(row_acc, {x, y}, c)
      end)
    end)
  end

  defp step(map) do
    map
    |> Enum.map(&step_tile(&1, map))
    |> Enum.into(%{})
  end

  defp step_tile({pos, "."}, map), do: if Map.get(adj_count(pos, map), "|", 0) >= 3, do: {pos, "|"}, else: {pos, "."}
  defp step_tile({pos, "|"}, map), do: if Map.get(adj_count(pos, map), "#", 0) >= 3, do: {pos, "#"}, else: {pos, "|"}
  defp step_tile({pos, "#"}, map) do
    count = adj_count(pos, map)
    if Map.get(count, "#", 0) >= 1 and Map.get(count, "|", 0) >= 1, do: {pos, "#"}, else: {pos, "."}
  end

  defp adj_count({x, y}, map) do
    [{x-1, y-1}, {x, y-1}, {x+1, y-1}, {x-1, y}, {x+1, y}, {x-1, y+1}, {x, y+1}, {x+1, y+1}]
    |> Enum.map(&(map[&1]))
    |> Enum.frequencies()
  end

  defp resource_value(map) do
    Enum.count(map, &(elem(&1, 1) == "|")) * Enum.count(map, &(elem(&1, 1) == "#"))
  end

  def vis(map) do
    {{x_min, _}, {x_max, _}} = map |> Map.keys() |> Enum.min_max_by(&elem(&1, 0))
    {{_, y_min}, {_, y_max}} = map |> Map.keys() |> Enum.min_max_by(&elem(&1, 1))

    Enum.each(y_min..y_max, fn y ->
      Enum.each(x_min..x_max, fn x ->
        IO.write(map[{x, y}])
      end)
      IO.write("\n")
    end)
    IO.write("\n")
  end
end

input = File.read!("input/18.txt")

input |> Eighteen.part_one() |> IO.inspect(label: "part 1")
input |> Eighteen.part_two() |> IO.inspect(label: "part 2")
