defmodule TwentyFive do
  def part_one(input) do
    input
    |> parse()
    |> constellations()
  end

  defp parse(text) do
    text
    |> String.trim()
    |> String.split(~r/\R/)
    |> Enum.map(fn line ->
      Regex.scan(~r/-*\d+/, line)
      |> List.flatten()
      |> Enum.map(&String.to_integer/1)
      |> List.to_tuple()
    end)
  end

  defp constellations(list) do
    list
    |> Enum.map(fn star -> [star] end)
    |> constellations(0)
  end

  defp constellations([], n), do: n
  defp constellations([constellation | rest], n) do
    connection_i =
      Enum.find_index(rest, fn target_constellation ->
        Enum.any?(constellation, fn star ->
          Enum.any?(target_constellation, fn target_star ->
            manhattan(star, target_star) <= 3
          end)
        end)
      end)
    if connection_i do
      List.update_at(rest, connection_i, &(constellation ++ &1))
      |> constellations(n)
    else
      constellations(rest, n + 1)
    end
  end

  defp manhattan({a, b, c, d}, {w, x, y, z}) do
    abs(a - w) + abs(b - x) + abs(c - y) + abs(d - z)
  end
end

input = File.read!("input/25.txt")

input |> TwentyFive.part_one() |> IO.inspect(label: "part 1")
