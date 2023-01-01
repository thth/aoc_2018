defmodule TwentyThree do
  def part_one(input) do
    input
    |> parse()
    |> then(fn bots ->
      {unrivaled_beanth_the_heavens, r} = Enum.max_by(bots, &elem(&1, 1))
      Enum.count(bots, fn {pos, _} ->
        manhattan(unrivaled_beanth_the_heavens, pos) <= r
      end)
    end)
  end

  def part_two(input) do
    input
    |> parse()
    |> find()
  end

  defp parse(text) do
    text
    |> String.trim()
    |> String.split(~r/\R/)
    |> Enum.map(fn line ->
      Regex.scan(~r/\-*\d+/, line)
      |> List.flatten()
      |> Enum.map(&String.to_integer/1)
      |> then(fn [x, y, z, r] -> {{x, y, z}, r} end)
    end)
  end

  defp manhattan({a, b, c}, {x, y, z}) do
    abs(x - a) + abs(b - y) + abs(z - c)
  end

  defp intersecting?({{a, b, c}, r}, {x_min..x_max, y_min..y_max, z_min..z_max}) do
    x_d = if a >= x_min and a <= x_max, do: 0, else: max(x_min - a, a - x_max)
    y_d = if b >= y_min and b <= y_max, do: 0, else: max(y_min - b, b - y_max)
    z_d = if c >= z_min and c <= z_max, do: 0, else: max(z_min - c, c - z_max)

    r >= (x_d + y_d + z_d)
  end

  defp d_to_origin({x_min..x_max, y_min..y_max, z_min..z_max}) do
    x_d = if 0 >= x_min and 0 <= x_max, do: 0, else: max(x_min - 0, 0 - x_max)
    y_d = if 0 >= y_min and 0 <= y_max, do: 0, else: max(y_min - 0, 0 - y_max)
    z_d = if 0 >= z_min and 0 <= z_max, do: 0, else: max(z_min - 0, 0 - z_max)

    x_d + y_d + z_d
  end

  defp sort_key({x_min..x_max, y_min..y_max, z_min..z_max} = range, bots) do
    n_bots = Enum.count(bots, &intersecting?(&1, range))
    d_origin = d_to_origin(range)
    size = (x_max - x_min + 1) * (y_max - y_min + 1) * (z_max - z_min + 1)
    {n_bots, d_origin, size}
  end

  defp sort_spaces(spaces) do
    Enum.sort_by(spaces, &elem(&1, 0), fn {a_bots, a_d, a_size}, {b_bots, b_d, b_size} ->
      cond do
        a_bots > b_bots -> true
        a_bots < b_bots -> false
        a_d < b_d -> true
        a_d > b_d -> false
        a_size < b_size -> true
        true -> false
      end
    end)
  end

  defp split({_, {x_min..x_max, y_min..y_max, z_min..z_max}}, bots) do
    x_h = div(x_min + x_max, 2)
    y_h = div(y_min + y_max, 2)
    z_h = div(z_min + z_max, 2)

    [
      {x_min..x_h, y_h+1..y_max, z_h+1..z_max},
      {x_h+1..x_max, y_h+1..y_max, z_h+1..z_max},
      {x_min..x_h, y_min..y_h, z_h+1..z_max},
      {x_h+1..x_max, y_min..y_h, z_h+1..z_max},
      {x_min..x_h, y_h+1..y_max, z_min..z_h},
      {x_h+1..x_max, y_h+1..y_max, z_min..z_h},
      {x_min..x_h, y_min..y_h, z_min..z_h},
      {x_h+1..x_max, y_min..y_h, z_min..z_h}
    ]
    |> Enum.map(fn range -> {sort_key(range, bots), range} end)
  end

  defp find(bots) do
    {{{x_min, _, _}, _}, {{x_max, _, _}, _}} = Enum.min_max_by(bots, fn {{a, _, _}, _} -> a end)
    {{{_, y_min, _}, _}, {{_, y_max, _}, _}} = Enum.min_max_by(bots, fn {{_, b, _}, _} -> b end)
    {{{_, _, z_min}, _}, {{_, _, z_max}, _}} = Enum.min_max_by(bots, fn {{_, _, c}, _} -> c end)

    range = {x_min..x_max, y_min..y_max, z_min..z_max}
    key = sort_key(range, bots)

    find([{key, range}], bots)
  end

  defp find([{{_, d, 1}, _} | _], _), do: d
  defp find([space | rest], bots) do
    (split(space, bots) ++ rest)
    |> sort_spaces()
    |> find(bots)
  end
end

input = File.read!("input/23.txt")

input |> TwentyThree.part_one() |> IO.inspect(label: "part 1")
input |> TwentyThree.part_two() |> IO.inspect(label: "part 2")
