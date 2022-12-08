defmodule Thirteen do
  def part_one(input) do
    {carts, map} = parse(input)
    find_crash(carts, map)
    |> then(fn {x, y} -> "#{x},#{y}" end)
  end

  def part_two(input) do
    {carts, map} = parse(input)
    find_last(carts, map)
    |> then(fn {x, y} -> "#{x},#{y}" end)
  end

  defp parse(text) do
    map =
      text
      |> String.split(~r/\R/)
      |> Enum.map(fn line ->
        line
        |> String.graphemes()
        |> Enum.with_index()
      end)
      |> Enum.with_index()
      |> Enum.reduce(%{}, fn {line, y}, acc ->
        Enum.reduce(line, acc, fn
          {" ", _}, a -> a
          {c, x}, a -> Map.put(a, {x, y}, c)
        end)
      end)
    carts =
      map
      |> Enum.filter(fn {_, v} -> v in ~w[^ v < >] end)
      |> Enum.map(fn {pos, dir} -> {pos, dir, :left} end)
      |> sort_carts()

    map =
      map
      |> Enum.map(fn
        {pos, dir} when dir in ~w[^ v] -> {pos, "|"}
        {pos, dir} when dir in ~w[< >] -> {pos, "-"}
        kv -> kv
      end)
      |> Enum.into(%{})

    {carts, map}
  end

  defp sort_carts(carts) do
    Enum.sort(carts, fn {{a_x, a_y}, _, _}, {{b_x, b_y}, _, _} ->
      a_y < b_y or (a_y == b_y and a_x < b_x)
    end)
  end

  defp find_crash(carts, map), do: find_crash(carts, [], map)
  defp find_crash([], moved, map), do: find_crash(sort_carts(moved), [], map)
  defp find_crash([cart | rest], moved, map) do
    {pos, _, _} = moved_cart = move_cart(cart, map)

    if pos in cart_positions(rest) or pos in cart_positions(moved) do
      pos
    else
      find_crash(rest, [moved_cart | moved], map)
    end
  end

  defp find_last(carts, map), do: find_last(carts, [], map)
  defp find_last([], [{pos, _, _}], _), do: pos
  defp find_last([], moved, map), do: find_last(sort_carts(moved), [], map)
  defp find_last([cart | rest], moved, map) do
    {pos, _, _} = moved_cart = move_cart(cart, map)

    cond do
      pos in cart_positions(rest) ->
        new_rest = Enum.reject(rest, fn {p, _, _} -> p == pos end)
        find_last(new_rest, moved, map)
      pos in cart_positions(moved) ->
        new_moved = Enum.reject(moved, fn {p, _, _} -> p == pos end)
        find_last(rest, new_moved, map)
      true ->
        find_last(rest, [moved_cart | moved], map)
    end
  end

  defp move_cart({pos, dir_to_move, state}, map) do
    case next({pos, dir_to_move, map}) do
      {next_pos, track} when track in ~w[| -] ->
        {next_pos, dir_to_move, state}
      {next_pos, "/"} ->
        case dir_to_move do
          "^" -> {next_pos, ">", state}
          "v" -> {next_pos, "<", state}
          "<" -> {next_pos, "v", state}
          ">" -> {next_pos, "^", state}
        end
      {next_pos, "\\"} ->
        case dir_to_move do
          "^" -> {next_pos, "<", state}
          "v" -> {next_pos, ">", state}
          "<" -> {next_pos, "^", state}
          ">" -> {next_pos, "v", state}
        end
      {next_pos, "+"} ->
        {next_dir, next_state} = intersection(dir_to_move, state)
        {next_pos, next_dir, next_state}
    end
  end

  defp next({{x, y}, "^", map}), do: {{x, y - 1}, map[{x, y - 1}]}
  defp next({{x, y}, "v", map}), do: {{x, y + 1}, map[{x, y + 1}]}
  defp next({{x, y}, "<", map}), do: {{x - 1, y}, map[{x - 1, y}]}
  defp next({{x, y}, ">", map}), do: {{x + 1, y}, map[{x + 1, y}]}

  defp intersection("^", :left), do: {"<", :straight}
  defp intersection("v", :left), do: {">", :straight}
  defp intersection("<", :left), do: {"v", :straight}
  defp intersection(">", :left), do: {"^", :straight}
  defp intersection("^", :straight), do: {"^", :right}
  defp intersection("v", :straight), do: {"v", :right}
  defp intersection("<", :straight), do: {"<", :right}
  defp intersection(">", :straight), do: {">", :right}
  defp intersection("^", :right), do: {">", :left}
  defp intersection("v", :right), do: {"<", :left}
  defp intersection("<", :right), do: {"^", :left}
  defp intersection(">", :right), do: {"v", :left}

  defp cart_positions(carts), do: Enum.map(carts, &elem(&1, 0))
end

input = File.read!("input/13.txt")

input |> Thirteen.part_one() |> IO.inspect(label: "part 1")
input |> Thirteen.part_two() |> IO.inspect(label: "part 2")
