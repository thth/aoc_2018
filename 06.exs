defmodule Six do
  @max_sum 10_000

  def part_one(input) do
    coords = parse(input)
    {{x_min, _}, {x_max, _}} = Enum.min_max_by(coords, fn {x, _} -> x end)
    {{_, y_min}, {_, y_max}} = Enum.min_max_by(coords, fn {_, y} -> y end)
    map =
      for x <- x_min..x_max,
          y <- y_min..y_max,
          into: %{} do
        {{x, y}, closests({x, y}, coords)}
      end
    infinites =
      map
      |> Enum.filter(fn {{x, y}, _} -> x in [x_min, x_max] or y in [y_min, y_max] end)
      |> Enum.into(%{})
      |> Map.values()
      |> Enum.filter(&(length(&1) == 1))
      |> List.flatten()
      |> Enum.map(fn {coord, _} -> coord end)
      |> Enum.uniq()

    map
    |> Enum.filter(fn {_, coords} -> length(coords) == 1 end)
    |> Enum.map(fn {_, [{coord, _}]} -> coord end)
    |> Enum.reject(fn coord -> coord in infinites end)
    |> Enum.frequencies()
    |> Enum.max_by(fn {_, n} -> n end)
    |> elem(1)
  end

  def part_two(input) do
    coords = parse(input)
    {{x_min, _}, {x_max, _}} = Enum.min_max_by(coords, fn {x, _} -> x end)
    {{_, y_min}, {_, y_max}} = Enum.min_max_by(coords, fn {_, y} -> y end)

    for x <- x_min..x_max,
        y <- y_min..y_max do
      {{x, y}, manhattan_sum({x, y}, coords)}
    end
    |> Enum.filter(fn {_, s} -> s < @max_sum end)
    |> Enum.count()
  end

  defp parse(text) do
    text
    |> String.trim()
    |> String.split(~r/[^\d]/, trim: true)
    |> Enum.map(&String.to_integer/1)
    |> Enum.chunk_every(2)
    |> Enum.map(&List.to_tuple/1)
  end

  defp closests(pos, coords) do
    coords
    |> Enum.map(fn coord -> {coord, manhattan(pos, coord)} end)
    |> Enum.sort_by(fn {_, d} -> d end)
    |> Enum.chunk_by(fn {_, d} -> d end)
    |> List.first()
  end

  defp manhattan({x1, y1}, {x2, y2}) do
    abs(x2 - x1) + abs(y2 - y1)
  end

  defp manhattan_sum(pos, coords) do
    coords
    |> Enum.map(&manhattan(pos, &1))
    |> Enum.sum()
  end
end

input = File.read!("input/06.txt")

input |> Six.part_one() |> IO.inspect(label: "part 1")
input |> Six.part_two() |> IO.inspect(label: "part 2")
