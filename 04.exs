defmodule Four do
  def part_one(input) do
    input
    |> parse()
    |> Enum.max_by(fn {_guard, sleeps, _shifts} ->
      sleeps
      |> Enum.map(fn {_min, times} -> times end)
      |> Enum.sum()
    end)
    |> (fn {guard, sleeps, _prob} ->
      sleeps
      |> Enum.max_by(fn {_, times} -> times end)
      |> elem(0)
      |> Kernel.*(guard)
    end).()
  end

  def part_two(input) do
    input
    |> parse()
    |> Enum.reject(fn {_, sleeps, _} -> sleeps == %{} end)
    |> Enum.map(fn {guard, sleeps, _shifts} ->
      {min, times} = sleeps |> Enum.max_by(fn {_min, times} -> times end)
      {guard, min, times}
    end)
    |> Enum.max_by(fn {_guard, _min, times} -> times end)
    |> (fn {guard, min, _times} -> guard * min end).()
  end

  defp parse(text) do
    text
    |> String.trim()
    |> String.split(~r/\R/)
    |> Enum.map(&String.split(&1, [" ", "[", "]"], trim: true))
    |> Enum.sort()
    |> Enum.chunk_while([],
      fn
        log, [] ->
          {:cont, [log]}
        log, acc ->
          if length(log) == 6 do
            {:cont, Enum.reverse(acc), [log]}
          else
            {:cont, [log | acc]}
          end
      end,
      fn acc -> {:cont, Enum.reverse(acc), []} end
    )
    |> Enum.reduce(%{}, fn [guard_log | logs], acc ->
      guard = guard_log |> Enum.at(3) |> String.trim("#") |> String.to_integer()
      sleeps =
        logs
        |> Enum.map(fn log ->
          log
          |> Enum.at(1)
          |> String.slice(3, 2)
          |> String.to_integer()
        end)
        |> Enum.chunk_every(2)
        |> Enum.map(fn [a, b] -> a..(b - 1) end)

      Map.update(acc, guard, [sleeps], &([sleeps | &1]))
    end)
    |> Enum.map(fn {guard, days} ->
      shifts = length(days)
      sleeps =
        days
        |> Enum.reduce(%{}, fn day, map ->
          Enum.reduce(day, map, fn range, acc ->
            Enum.reduce(range, acc, fn min, accc ->
              Map.update(accc, min, 1, &(&1 + 1))
            end)
          end)
        end)
      {guard, sleeps, shifts}
    end)
  end

end

input = File.read!("input/04.txt")

input |> Four.part_one() |> IO.inspect(label: "part 1")
input |> Four.part_two() |> IO.inspect(label: "part 2")
