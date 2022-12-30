defmodule Sixteen do
  import Bitwise

  @ops_list [:addr, :addi, :mulr, :muli, :banr, :bani, :borr, :bori, :setr, :seti, :gtir, :gtri, :gtrr, :eqir, :eqri, :eqrr]

  def part_one(input) do
    input
    |> parse()
    |> then(fn {samples, _} -> samples end)
    |> Enum.count(fn {before, instruction, result} ->
      Enum.count(@ops_list, fn ins -> op(ins, before, instruction) == result end) >= 3
    end)
  end

  def part_two(input) do
    input
    |> parse()
    |> then(fn {samples, program} ->
      samples
      |> Enum.group_by(fn {_, [opcode | _], _} -> opcode end)
      |> Enum.map(fn {opcode, op_samples} ->
        Enum.filter(@ops_list, fn ins ->
          Enum.all?(op_samples, fn {before, instruction, result} ->
            op(ins, before, instruction) == result
          end)
        end)
        |> then(fn ins -> {opcode, ins} end)
      end)
      |> then(fn possibility_list -> {%{}, possibility_list} end)
      |> Stream.iterate(fn {map, possibility_list} ->
        {opcode, [ins]} = Enum.min_by(possibility_list, fn {_, possible} -> length(possible) end)
        new_list =
          possibility_list
          |> Enum.map(fn {opcode, possible} -> {opcode, possible -- [ins]} end)
          |> Enum.reject(fn {_, possible} -> possible == [] end)

        {Map.put(map, opcode, ins), new_list}
      end)
      |> Enum.find_value(fn
        {map, []} -> map
        _ -> false
      end)
      |> then(fn ins_map ->
        program
        |> Enum.reduce([0, 0, 0, 0], fn [opcode | _] = instruction, register ->
          op(ins_map[opcode], register, instruction)
        end)
      end)
      |> Enum.at(0)
    end)
  end

  defp parse(text) do
    text
    |> String.trim()
    |> String.split(~r/\R\R\R/)
    |> then(fn [samples, program] ->
      samples =
        samples
        |> String.split(~r/\R\R/)
        |> Enum.map(fn block ->
          Regex.scan(~r/\-*\d+/, block)
          |> List.flatten()
          |> Enum.map(&String.to_integer/1)
          |> Enum.chunk_every(4)
          |> List.to_tuple()
        end)

        program =
          program
          |> String.split(~r/\R/, trim: true)
          |> Enum.map(fn line ->
            String.split(line, " ")
            |> Enum.map(&String.to_integer/1)
          end)

        {samples, program}
    end)
  end

  defp op(:addr, reg, [_, a, b, c]), do: List.replace_at(reg, c, Enum.at(reg, a) + Enum.at(reg, b))
  defp op(:addi, reg, [_, a, b, c]), do: List.replace_at(reg, c, Enum.at(reg, a) + b)
  defp op(:mulr, reg, [_, a, b, c]), do: List.replace_at(reg, c, Enum.at(reg, a) * Enum.at(reg, b))
  defp op(:muli, reg, [_, a, b, c]), do: List.replace_at(reg, c, Enum.at(reg, a) * b)
  defp op(:banr, reg, [_, a, b, c]), do: List.replace_at(reg, c, Enum.at(reg, a) &&& Enum.at(reg, b))
  defp op(:bani, reg, [_, a, b, c]), do: List.replace_at(reg, c, Enum.at(reg, a) &&& b)
  defp op(:borr, reg, [_, a, b, c]), do: List.replace_at(reg, c, Enum.at(reg, a) ||| Enum.at(reg, b))
  defp op(:bori, reg, [_, a, b, c]), do: List.replace_at(reg, c, Enum.at(reg, a) ||| b)
  defp op(:setr, reg, [_, a, _, c]), do: List.replace_at(reg, c, Enum.at(reg, a))
  defp op(:seti, reg, [_, a, _, c]), do: List.replace_at(reg, c, a)
  defp op(:gtir, reg, [_, a, b, c]), do: List.replace_at(reg, c, (if a > Enum.at(reg, b), do: 1, else: 0))
  defp op(:gtri, reg, [_, a, b, c]), do: List.replace_at(reg, c, (if Enum.at(reg, a) > b, do: 1, else: 0))
  defp op(:gtrr, reg, [_, a, b, c]), do: List.replace_at(reg, c, (if Enum.at(reg, a) > Enum.at(reg, b), do: 1, else: 0))
  defp op(:eqir, reg, [_, a, b, c]), do: List.replace_at(reg, c, (if a == Enum.at(reg, b), do: 1, else: 0))
  defp op(:eqri, reg, [_, a, b, c]), do: List.replace_at(reg, c, (if Enum.at(reg, a) == b, do: 1, else: 0))
  defp op(:eqrr, reg, [_, a, b, c]), do: List.replace_at(reg, c, (if Enum.at(reg, a) == Enum.at(reg, b), do: 1, else: 0))
end

input = File.read!("input/16.txt")

input |> Sixteen.part_one() |> IO.inspect(label: "part 1")
input |> Sixteen.part_two() |> IO.inspect(label: "part 2")
