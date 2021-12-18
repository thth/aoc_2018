defmodule Eleven do
  def part_one(input) do
    input
    |> parse()
    |> make_grid()
    |> find()
    |> then(fn {x, y, _} -> "#{x},#{y}" end)
  end

  # runs in 4 hours :)
  def part_two(input) do
    input
    |> parse()
    |> make_grid()
    |> find_any()
    |> then(fn {x, y, n} -> "#{x},#{y},#{n}" end)
  end

  defp parse(text) do
    text
    |> String.trim()
    |> String.to_integer()
  end

  defp make_grid(serial) do
    for x <- 1..300,
        y <- 1..300,
        into: %{} do
      {{x, y}, power({x, y}, serial)}
    end
  end

  defp power({x, y}, serial) do
    rack_id = x + 10

    rack_id
    |> Kernel.*(y)
    |> Kernel.+(serial)
    |> Kernel.*(rack_id)
    |> Integer.digits()
    |> Enum.at(-3, 0)
    |> Kernel.-(5)
  end

  defp find(grid) do
    (for x <- 1..298, y <- 1..298, do: {x, y, 3})
    |> Enum.max_by(&square_power(grid, &1))
  end

  defp square_power(grid, {x, y, n}) do
    (for j <- x..(x + n - 1), k <- y..(y + n - 1), do: {j, k})
    |> Enum.map(&Map.fetch!(grid, &1))
    |> Enum.sum()
  end

  defp find_any(grid) do
    for x <- 1..300,
        y <- 1..300,
        n <- 1..300,
        301 - max(x, y) - n >= 0 do
      {x, y, n}
    end
    |> Enum.max_by(fn {x, y, n} ->
      # if n == 1, do: IO.inspect({x, y})
      square_power(grid, {x, y, n})
    end)
  end
end

input = File.read!("input/11.txt")

input |> Eleven.part_one() |> IO.inspect(label: "part 1")
# start = System.monotonic_time(:second)
input |> Eleven.part_two() |> IO.inspect(label: "part 2")

# finish = System.monotonic_time(:second)
# IO.inspect("#{finish - start}s")
