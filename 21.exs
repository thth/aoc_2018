defmodule TwentyOne do
  import Bitwise

  def part_one(input) do
    input
    |> parse()
    |> then(fn {ip, ins_map} ->
      {opcode, r} = Enum.find_value(ins_map, fn {oc, [ins, a, b, _]} ->
        ins == "eqrr" && (if a == 0, do: {oc, b}, else: {oc, a})
      end)

      Stream.iterate(new_reg(0), &step(&1, ip, ins_map))
      |> Enum.find(fn reg -> Map.fetch!(reg, ip) == opcode end)
      |> Map.fetch!(r)
    end)
  end

  # runs in 9min
  def part_two(input) do
    input
    |> parse()
    |> then(fn {ip, ins_map} ->
      {opcode, r} = Enum.find_value(ins_map, fn {oc, [ins, a, b, _]} ->
        ins == "eqrr" && (if a == 0, do: {oc, b}, else: {oc, a})
      end)

      Stream.iterate(new_reg(0), &step(&1, ip, ins_map))
      |> Enum.reduce_while({MapSet.new(), nil}, fn reg, {seen, last} ->
        if Map.fetch!(reg, ip) == opcode do
          n = Map.fetch!(reg, r)
          if MapSet.member?(seen, n), do: {:halt, last}, else: {:cont, {MapSet.put(seen, n), n}}
        else
          {:cont, {seen, last}}
        end
      end)
    end)
  end

  defp parse(text) do
    text
    |> String.trim()
    |> String.split(~r/\R/)
    |> then(fn ["#ip " <> ip | instructions] ->
      instructions
      |> Enum.map(fn line ->
        line
        |> String.split(" ")
        |> Enum.map(fn str ->
          case Integer.parse(str) do
            {n, ""} -> n
            :error -> str
          end
        end)
      end)
      |> Enum.with_index()
      |> Enum.map(fn {ins, i} -> {i, ins} end)
      |> Enum.into(%{})
      |> then(fn map -> {String.to_integer(ip), map} end)
    end)
  end

  defp step(reg, ip, ins_map) do
    case ins_map[Map.fetch!(reg, ip)] do
      nil -> {:halt, reg}
      ins ->
        reg
        |> op(ins)
        |> Map.update!(ip, &(&1 + 1))
    end
  end

  defp op(reg, ["addr", a, b, c]), do: Map.put(reg, c, Map.fetch!(reg, a) + Map.fetch!(reg, b))
  defp op(reg, ["addi", a, b, c]), do: Map.put(reg, c, Map.fetch!(reg, a) + b)
  defp op(reg, ["mulr", a, b, c]), do: Map.put(reg, c, Map.fetch!(reg, a) * Map.fetch!(reg, b))
  defp op(reg, ["muli", a, b, c]), do: Map.put(reg, c, Map.fetch!(reg, a) * b)
  defp op(reg, ["banr", a, b, c]), do: Map.put(reg, c, Map.fetch!(reg, a) &&& Map.fetch!(reg, b))
  defp op(reg, ["bani", a, b, c]), do: Map.put(reg, c, Map.fetch!(reg, a) &&& b)
  defp op(reg, ["borr", a, b, c]), do: Map.put(reg, c, Map.fetch!(reg, a) ||| Map.fetch!(reg, b))
  defp op(reg, ["bori", a, b, c]), do: Map.put(reg, c, Map.fetch!(reg, a) ||| b)
  defp op(reg, ["setr", a, _, c]), do: Map.put(reg, c, Map.fetch!(reg, a))
  defp op(reg, ["seti", a, _, c]), do: Map.put(reg, c, a)
  defp op(reg, ["gtir", a, b, c]), do: Map.put(reg, c, (if a > Map.fetch!(reg, b), do: 1, else: 0))
  defp op(reg, ["gtri", a, b, c]), do: Map.put(reg, c, (if Map.fetch!(reg, a) > b, do: 1, else: 0))
  defp op(reg, ["gtrr", a, b, c]), do: Map.put(reg, c, (if Map.fetch!(reg, a) > Map.fetch!(reg, b), do: 1, else: 0))
  defp op(reg, ["eqir", a, b, c]), do: Map.put(reg, c, (if a == Map.fetch!(reg, b), do: 1, else: 0))
  defp op(reg, ["eqri", a, b, c]), do: Map.put(reg, c, (if Map.fetch!(reg, a) == b, do: 1, else: 0))
  defp op(reg, ["eqrr", a, b, c]), do: Map.put(reg, c, (if Map.fetch!(reg, a) == Map.fetch!(reg, b), do: 1, else: 0))

  defp new_reg(n) do
    Enum.map(1..5, fn r -> {r, 0} end)
    |> Enum.into(%{})
    |> Map.put(0, n)
  end
end

input = File.read!("input/21.txt")

input |> TwentyOne.part_one() |> IO.inspect(label: "part 1")
input |> TwentyOne.part_two() |> IO.inspect(label: "part 2")
