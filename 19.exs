defmodule Nineteen do
  # from Rosetta Code
  defmodule Proper do
    def divisors(1), do: []
    def divisors(n), do: [1 | divisors(2,n,:math.sqrt(n))] |> Enum.sort

    defp divisors(k,_n,q) when k>q, do: []
    defp divisors(k,n,q) when rem(n,k)>0, do: divisors(k+1,n,q)
    defp divisors(k,n,q) when k * k == n, do: [k | divisors(k+1,n,q)]
    defp divisors(k,n,q)                , do: [k,div(n,k) | divisors(k+1,n,q)]
  end

  import Bitwise

  def part_one(input) do
    input
    |> parse()
    |> run(List.duplicate(0, 6))
    |> List.first()
  end

  # prophetic solution divined from staring into the instructions
  def part_two(input) do
    input
    |> parse()
    |> then(fn {ip, ins_map} ->
      Stream.iterate([1, 0, 0, 0, 0, 0], &(&1 |> step(ip, ins_map) |> elem(1)))
    end)
    |> Enum.at(100)
    |> Enum.max()
    |> then(fn n -> Proper.divisors(n) ++ [n] end)
    |> Enum.sum()
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

  defp run({ip, ins_map}, reg), do: run(reg, ip, ins_map)
  defp run(reg, ip, ins_map) do
    case step(reg, ip, ins_map) do
      {:halt, new_reg} -> new_reg
      {:cont, new_reg} -> run(new_reg, ip, ins_map)
    end
  end

  defp step(reg, ip, ins_map) do
    case ins_map[Enum.at(reg, ip)] do
      nil -> {:halt, reg}
      ins ->
        reg
        |> op(ins)
        |> List.update_at(ip, &(&1 + 1))
        |> then(&({:cont, &1}))
    end
  end

  defp op(reg, ["addr", a, b, c]), do: List.replace_at(reg, c, Enum.at(reg, a) + Enum.at(reg, b))
  defp op(reg, ["addi", a, b, c]), do: List.replace_at(reg, c, Enum.at(reg, a) + b)
  defp op(reg, ["mulr", a, b, c]), do: List.replace_at(reg, c, Enum.at(reg, a) * Enum.at(reg, b))
  defp op(reg, ["muli", a, b, c]), do: List.replace_at(reg, c, Enum.at(reg, a) * b)
  defp op(reg, ["banr", a, b, c]), do: List.replace_at(reg, c, Enum.at(reg, a) &&& Enum.at(reg, b))
  defp op(reg, ["bani", a, b, c]), do: List.replace_at(reg, c, Enum.at(reg, a) &&& b)
  defp op(reg, ["borr", a, b, c]), do: List.replace_at(reg, c, Enum.at(reg, a) ||| Enum.at(reg, b))
  defp op(reg, ["bori", a, b, c]), do: List.replace_at(reg, c, Enum.at(reg, a) ||| b)
  defp op(reg, ["setr", a, _, c]), do: List.replace_at(reg, c, Enum.at(reg, a))
  defp op(reg, ["seti", a, _, c]), do: List.replace_at(reg, c, a)
  defp op(reg, ["gtir", a, b, c]), do: List.replace_at(reg, c, (if a > Enum.at(reg, b), do: 1, else: 0))
  defp op(reg, ["gtri", a, b, c]), do: List.replace_at(reg, c, (if Enum.at(reg, a) > b, do: 1, else: 0))
  defp op(reg, ["gtrr", a, b, c]), do: List.replace_at(reg, c, (if Enum.at(reg, a) > Enum.at(reg, b), do: 1, else: 0))
  defp op(reg, ["eqir", a, b, c]), do: List.replace_at(reg, c, (if a == Enum.at(reg, b), do: 1, else: 0))
  defp op(reg, ["eqri", a, b, c]), do: List.replace_at(reg, c, (if Enum.at(reg, a) == b, do: 1, else: 0))
  defp op(reg, ["eqrr", a, b, c]), do: List.replace_at(reg, c, (if Enum.at(reg, a) == Enum.at(reg, b), do: 1, else: 0))
end

input = File.read!("input/19.txt")

input |> Nineteen.part_one() |> IO.inspect(label: "part 1")
input |> Nineteen.part_two() |> IO.inspect(label: "part 2")
