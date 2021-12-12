defmodule Eight do
  def part_one(input) do
    input
    |> parse()
    |> get_data()
    |> Enum.sum()
  end

  def part_two(input) do
    input
    |> parse()
    |> value()
  end

  defp parse(text) do
    text
    |> String.trim()
    |> String.split(" ")
    |> Enum.map(&String.to_integer/1)
  end

  defp get_data([c, m | rest_list]), do: get_data(rest_list, [{c, m}], [])
  defp get_data([], _, data), do: data
  defp get_data(list, [{0, n} | rest_stack], data) do
    {new_data, rest_list} = Enum.split(list, n)
    get_data(rest_list, rest_stack, new_data ++ data)
  end
  defp get_data([c, m | rest_list], [{d, n} | rest_stack], data) do
    get_data(rest_list, [{c, m}, {d - 1, n} | rest_stack], data)
  end

  defp value([c, m | rest]), do: value(rest, [{c, m, [], nil}])
  defp value([], [{0, _m, _child_vals, val}]), do: val
  defp value(list, [{0, m, child_vals, nil} | rest_stack]) do
    {indicies, rest_list} = Enum.split(list, m)
    val = indicies |> Enum.map(&Enum.at(child_vals, &1 - 1, 0)) |> Enum.sum()
    value(rest_list, [{0, m, child_vals, val} | rest_stack])
  end
  defp value(list, [{0, _, _, val}, {c, m, child_vals, nil} | rest_stack]) do
    value(list, [{c, m, child_vals ++ [val], nil} | rest_stack])
  end
  defp value([0, m | list], [{c, n, child_vals, nil} | rest_stack]) do
    {values, rest_list} = Enum.split(list, m)
    value(rest_list, [{c - 1, n, child_vals ++ [Enum.sum(values)], nil} | rest_stack])
  end
  defp value([c, m | rest_list], [{d, n, child_vals, nil} | rest_stack]) do
    value(rest_list, [{c, m, [], nil}, {d - 1, n, child_vals, nil} | rest_stack])
  end
end

input = File.read!("input/08.txt")

input |> Eight.part_one() |> IO.inspect(label: "part 1")
input |> Eight.part_two() |> IO.inspect(label: "part 2")
