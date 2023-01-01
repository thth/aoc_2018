defmodule TwentyTwo do
  def part_one(input) do
    input
    |> parse()
    |> map()
    |> then(fn map ->
      {x_max, _} = map |> Map.keys() |> Enum.max_by(&elem(&1, 0))
      {_, y_max} = map |> Map.keys() |> Enum.max_by(&elem(&1, 1))

      Enum.reduce(0..y_max, 0, fn y, acc ->
        Enum.reduce(0..x_max, acc, fn x, row_acc -> row_acc + map[{x, y}] end)
      end)
    end)
  end

  # runs in 10s
  def part_two(input) do
    input
    |> parse()
    |> then(fn {depth, target} ->
      buffer = 20
      map({depth, target}, buffer)
      |> path()
      |> Map.get({target, :torch})
    end)
  end

  defp parse(text) do
    Regex.scan(~r/\d+/, text)
    |> List.flatten()
    |> Enum.map(&String.to_integer/1)
    |> then(fn [depth, x, y] -> {depth, {x, y}} end)
  end

  defp map({depth, {tx, ty}}, buffer \\ 0) do
    Enum.reduce(0..(ty+buffer), %{}, fn y, acc ->
      Enum.reduce(0..(tx+buffer), acc, fn x, row_acc ->
        index =
          case {x, y} do
            {0, 0} -> 0
            {^tx, ^ty} -> 0
            {^x, 0} -> x * 16807
            {0, ^y} -> y * 48271
            # I misread this as (index * index) instead of (erosion * erosion) at first...
            # was almost a spooky modular arithmatic problem
            {^x, ^y} -> row_acc[{x - 1, y}].erosion * row_acc[{x, y - 1}].erosion
          end
        erosion = rem(index + depth, 20183)
        type = rem(erosion, 3)
        Map.put(row_acc, {x, y}, %{index: index, erosion: erosion, type: type})
      end)
    end)
    |> Enum.map(fn {pos, %{type: type}} -> {pos, type} end)
    |> Enum.into(%{})
  end

  defp path(map), do: path([{{{0, 0}, :torch}, 0}], %{}, %{}, map)
  defp path([], next, seen, _) when map_size(next) == 0, do: seen
  defp path([], next, seen, map), do: path(Enum.to_list(next), %{}, seen, map)
  defp path([{{pos, state}, t} | rest], next, seen, map) do
    pos_type = map[pos]
    adjacent(pos, map)
    |> Enum.map(fn {adj, adj_type} ->
      case {state, pos_type, adj_type} do
        {:torch, _, 0} -> [{{adj, :torch}, t + 1}, {{adj, :gear}, t + 8}]
        {:torch, 0, 1} -> [{{adj, :gear}, t + 8}, {{adj, :none}, t + 15}]
        {:torch, 2, 1} -> [{{adj, :gear}, t + 15}, {{adj, :none}, t + 8}]
        {:torch, _, 2} -> [{{adj, :torch}, t + 1}, {{adj, :none}, t + 8}]
        {:gear, _, 0} -> [{{adj, :torch}, t + 8}, {{adj, :gear}, t + 1}]
        {:gear, _, 1} -> [{{adj, :gear}, t + 1}, {{adj, :none}, t + 8}]
        {:gear, 0, 2} -> [{{adj, :torch}, t + 8}, {{adj, :none}, t + 15}]
        {:gear, 1, 2} -> [{{adj, :torch}, t + 15}, {{adj, :none}, t + 8}]
        {:none, 1, 0} -> [{{adj, :torch}, t + 15}, {{adj, :gear}, t + 8}]
        {:none, 2, 0} -> [{{adj, :torch}, t + 8}, {{adj, :gear}, t + 15}]
        {:none, _, 1} -> [{{adj, :gear}, t + 8}, {{adj, :none}, t + 1}]
        {:none, _, 2} -> [{{adj, :torch}, t + 8}, {{adj, :none}, t + 1}]
      end
    end)
    |> List.flatten()
    |> Enum.reduce({next, seen}, fn {adj_state, adj_t}, {next_acc, seen_acc} ->
      case seen_acc[adj_state] do
        nil -> {Map.put(next_acc, adj_state, adj_t), Map.put(seen_acc, adj_state, adj_t)}
        seen_t when adj_t < seen_t -> {Map.put(next_acc, adj_state, adj_t), Map.put(seen_acc, adj_state, adj_t)}
        _ -> {next_acc, seen_acc}
      end
    end)
    |> then(fn {new_next, new_seen} ->
      path(rest, new_next, new_seen, map)
    end)
  end

  defp adjacent({x, y}, map) do
    [{x, y}, {x, y - 1}, {x, y + 1}, {x - 1, y}, {x + 1, y}]
    |> Enum.map(&({&1, map[&1]}))
    |> Enum.reject(&(elem(&1, 1) == nil))
  end
end

input = File.read!("input/22.txt")

input |> TwentyTwo.part_one() |> IO.inspect(label: "part 1")
input |> TwentyTwo.part_two() |> IO.inspect(label: "part 2")
