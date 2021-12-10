defmodule Five do
  def part_one(input) do
    input
    |> parse()
    |> react()
    |> length()
  end

  def part_two(input) do
    polymer = parse(input)

    ?a..?z
    |> Enum.map(fn n ->
      Enum.reject(polymer, fn str ->
        str
        |> String.downcase()
        |> String.to_charlist()
        |> Enum.at(0)
        |> Kernel.==(n)
      end)
    end)
    |> Enum.min_by(fn polymer ->
      polymer |> react() |> length()
    end)
    |> react()
    |> length()
  end

  defp parse(text) do
    text
    |> String.trim()
    |> String.graphemes()
  end

  defp react(units, next \\ [], reacted? \\ false)
  defp react([], next, false), do: Enum.reverse(next)
  defp react([], next, true), do: react(next, [], false)
  defp react([a], next, reacted?), do: react([], [a | next], reacted?)
  defp react([a, a | rest], next, reacted?), do: react([a | rest], [a | next], reacted?)
  defp react([a, b | rest], next, reacted?) do
    if String.capitalize(a) == b or String.capitalize(b) == a do
      react(rest, next, true)
    else
      react([b | rest], [a | next], reacted?)
    end
  end
end

input = File.read!("input/05.txt")

input |> Five.part_one() |> IO.inspect(label: "part 1")
input |> Five.part_two() |> IO.inspect(label: "part 2")
