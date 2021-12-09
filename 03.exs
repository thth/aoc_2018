defmodule Three do
  def part_one(input) do
    input
    |> parse()
    |> Enum.reduce(%{}, fn {_id, x, y, w, h}, coords ->
      for j <- x..(x + w - 1),
          k <- y..(y + h - 1) do
        {j, k}
      end
      |> Enum.reduce(coords, fn coord, acc ->
        Map.update(acc, coord, 1, &(&1 + 1))
      end)
    end)
    |> Enum.count(fn {_, n} -> n >= 2 end)
  end

  def part_two(input) do
    instructions = parse(input)

    map = Enum.reduce(instructions, %{}, fn {id, x, y, w, h}, coords ->
        for j <- x..(x + w - 1),
            k <- y..(y + h - 1) do
          {j, k}
        end
        |> Enum.reduce(coords, fn coord, acc ->
          Map.update(acc, coord, id, fn _ -> false end)
        end)
      end)

    instructions
    |> Enum.find(fn {id, _, _, w, h} ->
      Enum.count(map, fn {_, pos_id} -> id == pos_id end) == (w * h)
    end)
    |> elem(0)
  end

  defp parse(text) do
    text
    |> String.trim()
    |> String.split(~r/\R/)
    |> Enum.map(fn line ->
      line
      |> String.split(~r/[^\d]/, trim: true)
      |> Enum.map(&String.to_integer/1)
      |> List.to_tuple()
    end)
  end
end

input = File.read!("input/03.txt")

input
|> Three.part_one()
|> IO.inspect(label: "part 1")

input
|> Three.part_two()
|> IO.inspect(label: "part 2")
