defmodule Nine do
  def part_one(input) do
    {players, last} = parse(input)

    run(players, last)
    |> Map.values()
    |> Enum.max()
  end

  def part_two(input) do
    {players, last} = parse(input)

    run(players, last * 100)
    |> Map.values()
    |> Enum.max()
  end

  defp parse(text) do
    Regex.scan(~r/\d+/, text)
    |> Enum.take(2)
    |> List.flatten()
    |> Enum.map(&String.to_integer/1)
    |> List.to_tuple()
  end

  defp run(players, last), do: run(1, %{0 => {0, 0}}, 0, %{}, players, last)
  defp run(marble, _circle, _curr, scores, _players, last) when marble > last, do: scores
  defp run(marble, circle, curr, scores, players, last) when rem(marble, 23) == 0 do
    player = rem(marble, players)
    new_curr = prev(circle, curr, 6)
    remove = prev(circle, new_curr, 1)
    new_prev = prev(circle, remove, 1)
    new_scores = Map.update(scores, player, marble + remove, &(&1 + marble + remove))
    new_circle =
      circle
      |> Map.update!(new_prev, fn {p, _} -> {p, new_curr} end)
      |> Map.update!(new_curr, fn {_, n} -> {new_prev, n} end)
      |> Map.drop([remove])
    run(marble + 1, new_circle, new_curr, new_scores, players, last)
  end
  defp run(marble, circle, curr, scores, players, last) do
    new_prev = next(circle, curr, 1)
    new_next = next(circle, new_prev, 1)
    new_circle =
      circle
      |> Map.update!(new_prev, fn {p, _} -> {p, marble} end)
      |> Map.update!(new_next, fn {_, n} -> {marble, n} end)
      |> Map.put(marble, {new_prev, new_next})
    run(marble + 1, new_circle, marble, scores, players, last)
  end

  defp next(_circle, n, 0), do: n
  defp next(circle, n, times), do: next(circle, elem(circle[n], 1), times - 1)

  defp prev(_circle, n, 0), do: n
  defp prev(circle, n, times), do: prev(circle, elem(circle[n], 0), times - 1)
end

# start = System.monotonic_time(:millisecond)

input = File.read!("input/09.txt")

input |> Nine.part_one() |> IO.inspect(label: "part 1")
input |> Nine.part_two() |> IO.inspect(label: "part 2")

# finish = System.monotonic_time(:millisecond)
# IO.inspect("#{finish - start} ms")
