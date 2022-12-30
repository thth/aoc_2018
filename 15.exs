defmodule Fifteen do
  defmodule State do
    defstruct [:map, :units_unmoved, units_moved: [], rounds_completed: 0]
  end

  defmodule Unit do
    defstruct [:species, :pos, hp: 200, atk: 3]
  end

  def part_one(input) do
    input
    |> parse()
    |> simulate_until_end()
    |> combat_outcome()
  end

  # ran in 15s
  def part_two(input) do
    Stream.iterate(3, &(&1 + 1))
    |> Enum.find_value(fn atk ->
      input
      |> parse()
      |> then(fn state ->
        state = %State{state |
          units_unmoved: Enum.map(state.units_unmoved, fn unit ->
            if unit.species == "elf", do: %Unit{unit | atk: atk}, else: unit
          end)
        }
        simulated = simulate_until_end(state)
        elves_start = state |> units() |> Enum.count(&(&1.species == "elf"))
        elves_end = simulated |> units() |> Enum.count(&(&1.species == "elf"))

        if elves_start == elves_end, do: combat_outcome(simulated), else: false
      end)
    end)
  end

  defp parse(text) do
    text
    |> String.trim()
    |> String.split(~r/\R/)
    |> Enum.with_index()
    |> Enum.reduce({MapSet.new(), []}, fn {row, y}, acc ->
      row
      |> String.graphemes()
      |> Enum.with_index()
      |> Enum.reduce(acc, fn
        {"#", _}, row_acc -> row_acc
        {".", x}, {map, units} -> {MapSet.put(map, {x, y}), units}
        {"E", x}, {map, units} -> {MapSet.put(map, {x, y}), [%Unit{pos: {x, y}, species: "elf"} | units]}
        {"G", x}, {map, units} -> {MapSet.put(map, {x, y}), [%Unit{pos: {x, y}, species: "goblin"} | units]}
      end)
    end)
    |> then(fn {map, units} -> %State{map: map, units_unmoved: sort_reading_order(units)} end)
  end

  defp sort_reading_order(list) do
    Enum.sort_by(list, fn
      {x, y} -> {y, x}
      %Unit{pos: {x, y}} -> {y, x}
    end)
  end

  defp units(state), do: state.units_unmoved ++ state.units_moved

  defp moving_unit(%State{units_unmoved: [unit | _]}), do: unit

  defp simulate_until_end(state) do
    if Enum.all?(units(state), &(&1.species == "goblin")) or Enum.all?(units(state), &(&1.species == "elf")) do
      if state.units_unmoved == [], do: %State{state | rounds_completed: state.rounds_completed + 1}, else: state
    else
      state
      |> step()
      |> simulate_until_end()
    end
  end

  defp step(%State{units_unmoved: [], units_moved: units, rounds_completed: rounds} = state) do
    %State{state | units_unmoved: sort_reading_order(units), units_moved: [], rounds_completed: rounds + 1}
  end

  defp step(state) do
    state
    |> move()
    |> attack()
  end

  defp move(%State{units_unmoved: [unit | rest_unmoved], units_moved: moved} = state) do
    next_pos =
      with false <- enemies_adjacent?(state),
           {:ok, destination} <- find_destination(state) do
        state
        |> moving_unit()
        |> adjacent()
        |> Enum.filter(fn adjs -> MapSet.member?(empty_tiles(state), adjs) end)
        |> closest_to(destination, state)
      else
        _ -> unit.pos
      end

    %State{state |
      units_unmoved: rest_unmoved,
      units_moved: [%Unit{unit | pos: next_pos} | moved]
    }
  end

  defp attack(state) do
    if target = find_target(state) do
      unit_attack = hd(state.units_moved).atk
      cond do
        i = Enum.find_index(state.units_unmoved, &(&1 == target)) ->
          if target.hp > unit_attack do
            %State{state |
              units_unmoved: List.update_at(state.units_unmoved, i, fn t -> Map.update!(t, :hp, &(&1 - unit_attack)) end)
            }
          else
            %State{state |
              units_unmoved: List.delete_at(state.units_unmoved, i)
            }
          end
        i = Enum.find_index(state.units_moved, &(&1 == target)) ->
          if target.hp > unit_attack do
            %State{state |
              units_moved: List.update_at(state.units_moved, i, fn t -> Map.update!(t, :hp, &(&1 - unit_attack)) end)
            }
          else
            %State{state |
              units_moved: List.delete_at(state.units_moved, i)
            }
          end
      end
    else
      state
    end
  end

  defp find_destination(state) do
    enemies(state)
    |> Enum.map(&adjacent/1)
    |> List.flatten()
    |> Enum.uniq()
    |> Enum.filter(fn adjs -> MapSet.member?(empty_tiles(state), adjs) end)
    |> closest_to(moving_unit(state).pos, state)
    |> then(fn
      nil -> nil
      pos -> {:ok, pos}
    end)
  end

  defp closest_to(coords_list, pos, state) do
    distances_from(pos, state)
    |> Enum.filter(fn {coords, _} -> coords in coords_list end)
    |> then(fn
      [] -> nil
      coords_distances ->
        {_, min_d} = Enum.min_by(coords_distances, fn {_, d} -> d end)
        coords_distances
        |> Enum.filter(fn {_, d} -> d == min_d end)
        |> Enum.map(&(elem(&1, 0)))
        |> sort_reading_order()
        |> hd()
    end)
  end

  defp adjacent(%Unit{pos: {x, y}}), do: [{x, y - 1}, {x, y + 1}, {x - 1, y}, {x + 1, y}]
  defp adjacent({x, y}), do: [{x, y - 1}, {x, y + 1}, {x - 1, y}, {x + 1, y}]

  defp enemies(%State{units_unmoved: [%Unit{species: unit_species} | _]} = state) do
    Enum.filter(units(state), &(&1.species != unit_species))
  end

  defp enemies_adjacent?(state) do
    Enum.any?(enemies(state), fn %Unit{pos: pos} -> pos in adjacent(moving_unit(state)) end)
  end

  defp find_target(%State{units_moved: [%Unit{species: unit_species, pos: unit_pos} | _]} = state) do
    Enum.filter(units(state), fn unit ->
      unit.species != unit_species and unit.pos in adjacent(unit_pos)
    end)
    |> then(fn
      [] -> nil
      enemy_list ->
        %Unit{hp: min_hp} = Enum.min_by(enemy_list, &(&1.hp))
        enemy_list
        |> Enum.filter(&(&1.hp == min_hp))
        |> sort_reading_order()
        |> hd()
    end)
  end

  defp empty_tiles(state) do
    units(state)
    |> Enum.map(&(&1.pos))
    |> MapSet.new()
    |> then(fn unit_pos -> MapSet.difference(state.map, unit_pos) end)
  end

  defp distances_from(coords, state), do: distances_from([coords], [], empty_tiles(state), 0, %{coords => 0})
  defp distances_from([], [], _, _, distances), do: distances
  defp distances_from([], next, valid, d, distances), do: distances_from(next, [], valid, d + 1, distances)
  defp distances_from([pos | rest], next, valid, d, distances) do
    additions =
      adjacent(pos)
      |> Enum.filter(&MapSet.member?(valid, &1))
      |> Enum.reject(&Map.has_key?(distances, &1))
    new_distances = Enum.reduce(additions, distances, fn add, acc -> Map.put(acc, add, d) end)
    distances_from(rest, additions ++ next, valid, d, new_distances)
  end

  defp combat_outcome(state) do
    state
    |> units()
    |> Enum.map(&(&1.hp))
    |> Enum.sum()
    |> Kernel.*(state.rounds_completed)
  end

  # bonus visualization function for debugging!
  def vis(state) do
    {{x_min, _}, {x_max, _}} = Enum.min_max_by(state.map, &(elem(&1, 0)))
    {{_, y_min}, {_, y_max}} = Enum.min_max_by(state.map, &(elem(&1, 1)))

    IO.puts(state.rounds_completed + 1)
    Enum.each((y_min-1)..(y_max+1), fn y ->
      Enum.each((x_min-1)..(x_max+1), fn x ->
        cond do
          unit = Enum.find(units(state), &(&1.pos == {x, y})) ->
            if unit.species == "goblin", do: IO.write("G"), else: IO.write("E")
          MapSet.member?(empty_tiles(state), {x, y}) -> IO.write(".")
          true -> IO.write("#")
        end
      end)
      IO.write("\n")
    end)
  end
end

input = File.read!("input/15.txt")

input |> Fifteen.part_one() |> IO.inspect(label: "part 1")
input |> Fifteen.part_two() |> IO.inspect(label: "part 2")
