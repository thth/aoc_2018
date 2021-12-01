defmodule One do
  def part_one(input) do
    input
    |> parse()
    |> Enum.sum()
  end

  def part_two(input) do
    input
    |> parse()
    |> Stream.cycle()
    |> Enum.reduce_while({0, MapSet.new([0])}, fn x, {prev_f, memo} ->
      curr_f = prev_f + x
      if MapSet.member?(memo, curr_f) do
        {:halt, curr_f}
      else
        {:cont, {curr_f, MapSet.put(memo, curr_f)}}
      end
    end)
  end

  defp parse(text) do
    text
    |> String.trim()
    |> String.split(~r/\R/)
    |> Enum.map(fn n ->
      String.to_integer(n)
    end)
  end
end

input = File.read!("input/01.txt")

input
|> One.part_one()
|> IO.inspect(label: "part 1")

input
|> One.part_two()
|> IO.inspect(label: "part 2")
