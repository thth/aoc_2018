defmodule Seventeen do
  @x_spring 500

  def part_one(input) do
    input
    |> parse()
    |> flow()
    |> then(fn {past, settled} -> MapSet.union(past, settled) |> MapSet.size() end)
  end

  def part_two(input) do
    input
    |> parse()
    |> flow()
    |> then(fn {_, settled} -> MapSet.size(settled) end)
  end

  defp parse(text) do
    text
    |> String.trim()
    |> String.split(~r/\R/)
    |> Enum.map(fn line ->
      Regex.scan(~r/^\w|\-*\d+/, line)
      |> List.flatten()
      |> Enum.map(fn str -> if str not in ~w[x y], do: String.to_integer(str), else: str end)
    end)
    |> Enum.reduce(MapSet.new(), fn
      ["x", x, y_min, y_max], acc ->
        (for y <- y_min..y_max, do: {x, y})
        |> MapSet.new()
        |> MapSet.union(acc)
      ["y", y, x_min, x_max], acc ->
        (for x <- x_min..x_max, do: {x, y})
        |> MapSet.new()
        |> MapSet.union(acc)
    end)
  end

  defp flow(map) do
    {{_, y_min}, {_, y_max}} = Enum.min_max_by(map, &elem(&1, 1))
    flow([{@x_spring, y_min}], MapSet.new(), MapSet.new(), y_min..y_max, map)
  end

  defp flow([], past, settled, _, _), do: {past, settled}
  defp flow([{x, y_max} | rest], past, settled, y_min..y_max, map) do
    flow(rest, MapSet.put(past, {x, y_max}), settled, y_min..y_max, map)
  end
  defp flow([{x, y} | rest], past, settled, y_min..y_max, map) do
    cond do
      MapSet.member?(past, {x, y}) ->
        flow(rest, past, settled, y_min..y_max, map)
      not MapSet.member?(map, {x, y + 1}) ->
        flow([{x, y + 1} | rest], MapSet.put(past, {x, y}), settled, y_min..y_max, map)
      true ->
        case {flow_left({x, y}, map), flow_right({x, y}, map)} do
          {{left_flow, left_past}, {right_flow, right_past}} ->
            flow([left_flow, right_flow | rest], MapSet.union(past, MapSet.new(left_past ++ right_past ++ [{x, y}])), settled, y_min..y_max, map)
          {{left_flow, left_past}, right_past} ->
            flow([left_flow | rest], MapSet.union(past, MapSet.new(left_past ++ right_past ++ [{x, y}])), settled, y_min..y_max, map)
          {left_past, {right_flow, right_past}} ->
            flow([right_flow | rest], MapSet.union(past, MapSet.new(left_past ++ right_past ++ [{x, y}])), settled, y_min..y_max, map)
          {left_past, right_past} ->
            new_settled = MapSet.new(left_past ++ right_past ++ [{x, y}])
            flow([{@x_spring, y_min}], MapSet.new(), MapSet.union(settled, new_settled), y_min..y_max, MapSet.union(map, new_settled))
        end
    end
  end

  defp flow_left({x, y}, map), do: flow_left([{x, y}], map)
  defp flow_left([{x, y} | rest] = flowed, map) do
    blocked_left? = MapSet.member?(map, {x - 1, y})
    blocked_below? = MapSet.member?(map, {x, y + 1})
    cond do
      blocked_below? and blocked_left? -> flowed
      blocked_below? and not blocked_left? -> flow_left([{x - 1, y} | flowed], map)
      not blocked_below? -> {{x, y}, rest}
    end
  end

  defp flow_right({x, y}, map), do: flow_right([{x, y}], map)
  defp flow_right([{x, y} | rest] = flowed, map) do
    blocked_right? = MapSet.member?(map, {x + 1, y})
    blocked_below? = MapSet.member?(map, {x, y + 1})
    cond do
      blocked_below? and blocked_right? -> flowed
      blocked_below? and not blocked_right? -> flow_right([{x + 1, y} | flowed], map)
      not blocked_below? -> {{x, y}, rest}
    end
  end
end

input = File.read!("input/17.txt")

input |> Seventeen.part_one() |> IO.inspect(label: "part 1")
input |> Seventeen.part_two() |> IO.inspect(label: "part 2")
