defmodule Seven do
  def part_one(input) do
    input
    |> parse()
    |> run()
    |> Enum.join()
  end

  @workers 5
  def part_two(input) do
    input
    |> parse()
    |> run_with_help(@workers)
  end

  defp parse(input) do
    instructions =
      input
      |> String.trim()
      |> String.split(~r/\R/)
      |> Enum.map(fn line ->
        line
        |> String.split(" ")
        |> (&({Enum.at(&1, 1), Enum.at(&1, 7)})).()
      end)

    instructions
    |> Enum.map(&Tuple.to_list/1)
    |> List.flatten()
    |> Enum.uniq()
    |> Enum.sort()
    |> Enum.map(fn step ->
      needs =
        instructions
        |> Enum.filter(&(elem(&1, 1) == step))
        |> Enum.map(&elem(&1, 0))
        |> Enum.sort()
      {step, needs}
    end)
  end

  defp run(needs, ran \\ [])
  defp run([], ran), do: Enum.reverse(ran)
  defp run(needs, ran) do
    {to_run, _} = Enum.find(needs, fn {_, reqs} -> reqs == [] end)
    new_needs =
      needs
      |> Enum.reject(fn {step, _} -> step == to_run end)
      |> Enum.map(fn {step, steps} -> {step, steps -- [to_run]} end)
    run(new_needs, [to_run | ran])
  end

  defp run_with_help(needs, free_workers),
    do: run_with_help({needs, free_workers, [], 0})
  defp run_with_help({[], _, [], seconds}), do: seconds - 1
  defp run_with_help(state) do
    state
    |> progress_work()
    |> assign_work()
    |> progress_time()
    |> run_with_help()
  end

  defp progress_work({needs, free_workers, in_progress, seconds}) do
    {still_doing, done} = Enum.split_with(in_progress, fn {_step, t} -> t != 0 end)
    done_list = Enum.map(done, fn {step, 0} -> step end)
    new_needs = Enum.map(needs, fn {step, reqs} -> {step, reqs -- done_list} end)
    {new_needs, free_workers + length(done_list), still_doing, seconds}
  end

  defp assign_work({_, 0, _, _} = state), do: state
  defp assign_work({needs, free_workers, in_progress, seconds} = state) do
    case Enum.find(needs, fn {_, reqs} -> reqs == [] end) do
      {to_run, _} ->
        new_needs = Enum.reject(needs, fn {step, _} -> step == to_run end)
        new_in_progress = [{to_run, time(to_run)} | in_progress]
        assign_work({new_needs, free_workers - 1, new_in_progress, seconds})
      nil ->
        state
    end
  end

  defp progress_time({needs, free_workers, in_progress, seconds}) do
    new_in_progress = Enum.map(in_progress, fn {step, t} -> {step, t - 1} end)
    {needs, free_workers, new_in_progress, seconds + 1}
  end

  defp time(letter) do
    [n] = String.to_charlist(letter)
    61 + n - ?A
  end
end

input = File.read!("input/07.txt")

input |> Seven.part_one() |> IO.inspect(label: "part 1")
input |> Seven.part_two() |> IO.inspect(label: "part 2")
