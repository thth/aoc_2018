defmodule Fourteen do
  def part_one(input) do
    goal = input |> String.trim() |> String.to_integer()

    Stream.iterate({%{0 => 3, 1 => 7}, {0, 1}, 2}, &step/1)
    |> Enum.find(fn {_, _, recipes_length} -> recipes_length >= goal + 10 end)
    |> then(fn {recipes, _, _} ->
      goal..(goal + 9)
      |> Enum.map(&(recipes[&1]))
      |> Enum.join()
    end)
  end

  def part_two(input) do
    goal = input |> String.trim() |> String.graphemes() |> Enum.map(&String.to_integer/1)
    last = goal |> length() |> then(&(List.duplicate(0, &1 - 1))) |> Kernel.++([3, 7])
    Stream.iterate({%{0 => 3, 1 => 7}, {0, 1}, 2, last}, &step_two/1)
    |> Enum.find(fn {_, _, _, digits} ->
      goal == tl(digits) or goal == Enum.slice(digits, 0..-2)
    end)
    |> then(fn {_, _, len, digits} ->
      if goal == tl(digits) do
        len - length(goal)
      else
        len - length(goal) - 1
      end
    end)
  end

  defp step({recipes, {i_1, i_2}, recipes_length}) do
    score_1 = recipes[i_1]
    score_2 = recipes[i_2]
    {new_recipes, new_length} =
      case Integer.digits(score_1 + score_2) do
        [a] -> {recipes |> Map.put(recipes_length, a), recipes_length + 1}
        [a, b] -> {recipes |> Map.put(recipes_length, a) |> Map.put(recipes_length + 1, b), recipes_length + 2}
      end

    new_i_1 = rem(i_1 + 1 + score_1, new_length)
    new_i_2 = rem(i_2 + 1 + score_2, new_length)

    {new_recipes, {new_i_1, new_i_2}, new_length}
  end

  defp step_two({recipes, {i_1, i_2}, recipes_length, digits}) do
    score_1 = recipes[i_1]
    score_2 = recipes[i_2]
    {new_recipes, new_length, new_digits} =
      case Integer.digits(score_1 + score_2) do
        [a] -> {recipes |> Map.put(recipes_length, a), recipes_length + 1, tl(digits) ++ [a]}
        [a, b] -> {recipes |> Map.put(recipes_length, a) |> Map.put(recipes_length + 1, b), recipes_length + 2, tl(tl(digits)) ++ [a, b]}
      end

    new_i_1 = rem(i_1 + 1 + score_1, new_length)
    new_i_2 = rem(i_2 + 1 + score_2, new_length)

    {new_recipes, {new_i_1, new_i_2}, new_length, new_digits}
  end
end

input = File.read!("input/14.txt")

input |> Fourteen.part_one() |> IO.inspect(label: "part 1")
input |> Fourteen.part_two() |> IO.inspect(label: "part 2")
