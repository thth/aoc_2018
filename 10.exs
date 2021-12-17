defmodule Ten do
  def part_one(input) do
    input
    |> parse()
    |> run_until_small()
    |> elem(0)
    |> print()
  end

  def part_two(input) do
    input
    |> parse()
    |> run_until_small()
    |> elem(1)
  end

  defp parse(text) do
    Regex.scan(~r/[-\d]+/, text)
    |> List.flatten()
    |> Enum.map(&String.to_integer/1)
    |> Enum.chunk_every(4)
    |> Enum.map(fn [x, y, dx, dy] -> {{x, y}, {dx, dy}} end)
  end

  defp run_until_small(dots, last_area \\ :infinity, seconds \\ 0) do
    new_dots = run(dots)
    new_area = area(new_dots)

    if new_area > last_area do
      {dots, seconds}
    else
      run_until_small(new_dots, new_area, seconds + 1)
    end
  end

  defp run(dots, next \\ [])
  defp run([], next), do: Enum.reverse(next)

  defp run([{{x, y}, {dx, dy}} | rest], next) do
    new_dot = {{x + dx, y + dy}, {dx, dy}}
    run(rest, [new_dot | next])
  end

  defp area(dots) do
    {{{x_min, _}, _}, {{x_max, _}, _}} = Enum.min_max(dots)
    {{{_, y_min}, _}, {{_, y_max}, _}} = Enum.min_max_by(dots, fn {{_, y}, _} -> y end)

    w = x_max - x_min
    h = y_max - y_min

    w * h
  end

  defp print(dots) do
    coords = dots |> Enum.map(&elem(&1, 0)) |> MapSet.new()
    {{x_min, _}, {x_max, _}} = Enum.min_max(coords)
    {{_, y_min}, {_, y_max}} = Enum.min_max_by(coords, fn {_, y} -> y end)

    y_min..y_max
    |> Enum.each(fn y ->
      Enum.each(x_min..x_max, fn x ->
        if {x, y} in coords, do: IO.write("#"), else: IO.write(" ")
      end)

      IO.write("\n")
    end)
  end
end

input = File.read!("input/10.txt")

input |> Ten.part_one()
input |> Ten.part_two() |> IO.inspect(label: "part 2")
