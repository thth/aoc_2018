defmodule TwentyFour do
  defmodule Group do
    defstruct [:id, :faction, :units, :unit_hp, :immunities, :weaknesses, :unit_atk, :atk_type, :initiative,
      :target, targetted?: false]
  end

  def part_one(input) do
    input
    |> parse()
    |> Stream.iterate(&fight/1)
    |> Enum.find(fn groups ->
      Enum.all?(groups, &(&1.faction == "immune")) or Enum.all?(groups, &(&1.faction == "infection"))
    end)
    |> Enum.map(fn group -> group.units end)
    |> Enum.sum()
  end

  def part_two(input) do
    input
    |> parse()
    |> then(fn groups ->
      Stream.iterate(0, &(&1 + 1))
      |> Enum.find_value(fn boost ->
        groups
        |> Enum.map(fn group ->
          if group.faction == "immune", do: Map.update!(group, :unit_atk, &(&1 + boost)), else: group
        end)
        |> Stream.iterate(&fight/1)
        |> Stream.chunk_every(2, 1)
        |> Enum.find(fn [groups_before, groups_after] ->
          cond do
            groups_before == groups_after -> true
            Enum.all?(groups_after, &(&1.faction == "immune")) or Enum.all?(groups_after, &(&1.faction == "infection")) -> true
            true -> false
          end
        end)
        |> then(fn [groups_before, groups_after] ->
          cond do
            groups_before == groups_after -> false
            List.first(groups_after).faction == "immune" -> groups_after
            true -> false
          end
        end)
      end)
    end)
    |> Enum.map(fn group -> group.units end)
    |> Enum.sum()
  end

  defp parse(text) do
    text
    |> String.trim()
    |> String.split(~r/\R\R/)
    |> then(fn [goods, bads] ->
      (goods
      |> String.split(~r/\R/)
      |> tl()
      |> Enum.with_index(1)
      |> Enum.map(fn {line, i} ->
        [units, unit_hp, unit_atk, initiative] =
          Regex.scan(~r/\d+/, line) |> List.flatten() |> Enum.map(&String.to_integer/1)
        immunities =
          Regex.scan(~r/immune to|[a-z]+|;|\)/, line)
          |> List.flatten()
          |> then(fn list ->
            if Enum.member?(list, "immune to") do
              start = Enum.find_index(list, &(&1 == "immune to"))
              list = Enum.slice(list, start..-1)
              i = Enum.find_index(list, &(&1 == ")" or &1 == ";"))
              Enum.slice(list, 1..i-1)
            else
              []
            end
          end)
        weaknesses =
          Regex.scan(~r/weak to|[a-z]+|;|\)/, line)
          |> List.flatten()
          |> then(fn list ->
            if Enum.member?(list, "weak to") do
              start = Enum.find_index(list, &(&1 == "weak to"))
              list = Enum.slice(list, start..-1)
              i = Enum.find_index(list, &(&1 == ")" or &1 == ";"))
              Enum.slice(list, 1..i-1)
            else
              []
            end
          end)
        [atk_type] = Regex.run(~r/(\w+)\sdamage/, line, capture: :all_but_first)
        %Group{id: {"immune", i}, faction: "immune", units: units, unit_hp: unit_hp,
          unit_atk: unit_atk, immunities: immunities,
          weaknesses: weaknesses, atk_type: atk_type, initiative: initiative}
      end)) ++ (bads
        |> String.split(~r/\R/)
        |> tl()
        |> Enum.with_index(1)
        |> Enum.map(fn {line, i} ->
          [units, unit_hp, unit_atk, initiative] =
            Regex.scan(~r/\d+/, line) |> List.flatten() |> Enum.map(&String.to_integer/1)
          immunities =
            Regex.scan(~r/immune to|[a-z]+|;|\)/, line)
            |> List.flatten()
            |> then(fn list ->
              if Enum.member?(list, "immune to") do
                start = Enum.find_index(list, &(&1 == "immune to"))
                list = Enum.slice(list, start..-1)
                i = Enum.find_index(list, &(&1 == ")" or &1 == ";"))
                Enum.slice(list, 1..i-1)
              else
                []
              end
            end)
          weaknesses =
            Regex.scan(~r/weak to|[a-z]+|;|\)/, line)
            |> List.flatten()
            |> then(fn list ->
              if Enum.member?(list, "weak to") do
                start = Enum.find_index(list, &(&1 == "weak to"))
                list = Enum.slice(list, start..-1)
                i = Enum.find_index(list, &(&1 == ")" or &1 == ";"))
                Enum.slice(list, 1..i-1)
              else
                []
              end
            end)
          [atk_type] = Regex.run(~r/(\w+)\sdamage/, line, capture: :all_but_first)
          %Group{id: {"infection", i}, faction: "infection", units: units, unit_hp: unit_hp,
            unit_atk: unit_atk, immunities: immunities,
            weaknesses: weaknesses, atk_type: atk_type, initiative: initiative}
        end))
    end)
  end

  defp fight(groups) do
    groups
    |> target_phase()
    |> attack_phase()
    |> Enum.reject(fn group -> group.units <= 0 end)
    |> Enum.map(fn group -> %Group{group | target: nil, targetted?: false} end)
  end

  defp target_phase(groups) do
    groups = Enum.sort_by(groups, fn group -> {group.unit_atk * group.units, group.initiative} end, &>/2)
    Enum.reduce(groups, groups, fn %Group{id: targetting_id} = targetting, acc ->
      base_power = targetting.unit_atk * targetting.units
      target =
        acc
        |> Enum.reject(fn group -> targetting.faction == group.faction or group.targetted? or (targetting.atk_type in group.immunities) end)
        |> Enum.sort_by(fn group ->
          dmg = if targetting.atk_type in group.weaknesses, do: base_power * 2, else: base_power
          {dmg, group.unit_atk * group.units, group.initiative}
        end, &>/2)
        |> List.first()
      case target do
        nil -> acc
        %Group{id: target_id} ->
          targetting_i = Enum.find_index(acc, &(&1.id == targetting_id))
          target_i = Enum.find_index(acc, &(&1.id == target_id))
          acc
          |> List.update_at(targetting_i, &Map.put(&1, :target, target_id))
          |> List.update_at(target_i, &Map.put(&1, :targetted?, true))
      end
    end)
  end

  defp attack_phase(groups) do
    groups = Enum.sort_by(groups, fn group -> group.initiative end, &>/2)
    Enum.reduce(groups, groups, fn %Group{id: attacker_id}, acc ->
      attacker = Enum.find(acc, fn group -> group.id == attacker_id end)
      case attacker do
        %Group{target: nil} -> acc
        %Group{units: units} when units <= 0 -> acc
        _ ->
          base_dmg = attacker.units * attacker.unit_atk
          target_i = Enum.find_index(acc, &(&1.id == attacker.target))
          List.update_at(acc, target_i, fn target ->
            dmg = if attacker.atk_type in target.weaknesses, do: base_dmg * 2, else: base_dmg
            remaining = target.units - div(dmg, target.unit_hp)
            Map.put(target, :units, remaining)
          end)
      end
    end)
  end
end

input = File.read!("input/24.txt")

input |> TwentyFour.part_one() |> IO.inspect(label: "part 1")
input |> TwentyFour.part_two() |> IO.inspect(label: "part 2")
