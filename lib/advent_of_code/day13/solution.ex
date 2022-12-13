defmodule AdventOfCode.Day13.Solution do

  def run() do
    packets =
      File.read!(__DIR__ <> "/input.txt")
      |> String.split(["\n\n", "\n"])
      |> Enum.map(fn packet ->
        Code.eval_string(packet) |> elem(0)
      end)

    IO.puts("1: #{part1(packets)}")
    IO.puts("2: #{part2(packets)}")
  end

  def part1(packets) do
    packets
    |> Enum.chunk_every(2)
    |> Enum.with_index(1)
    |> Enum.reduce(0, fn {[lefts, rights], i}, acc ->
      if {:halt, true} == compare(lefts, rights), do: acc + i, else: acc
    end)
  end

  def compare([], []), do: {:cont, false}
  def compare([], _rights), do: {:halt, true}
  def compare(_lefts, []), do: {:halt, false}

  def compare([left | lefts], [right | rights]) when is_integer(left) and is_list(right) do
    compare([[left] | lefts], [right | rights])
  end

  def compare([left | lefts], [right | rights]) when is_list(left) and is_integer(right) do
    compare([left | lefts], [[right] | rights])
  end

  def compare([left | lefts], [right | rights]) when is_list(left) and is_list(right) do
    case compare(left, right) do
      {:cont, _answer} -> compare(lefts, rights)
      {:halt, answer} -> {:halt, answer}
    end
  end

  def compare([left | lefts], [right | rights]) when is_integer(left) and is_integer(right) do
    if left == right, do: compare(lefts, rights), else: {:halt, left < right}
  end

  def part2(packets) do
    divider_1 = [[2]]
    divider_2 = [[6]]

    packets = [divider_2 | [divider_1 | packets]]

    graph =
      packets
      |> Enum.reduce(%{}, fn packet, acc_og ->
        number_of_possibilities =
          packets -- [packet]
          |> Enum.reduce(0, fn rights, acc ->
            if compare(packet, rights) == {:halt, true}, do: acc + 1, else: acc
          end)

        acc_og
        |> Map.put(packet, number_of_possibilities)
      end)

    (length(packets) - Map.get(graph, divider_1)) * (length(packets) - Map.get(graph, divider_2))
  end
end
