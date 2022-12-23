defmodule AdventOfCode.Day20.Solution do

  def run() do
    numbers =
      File.read!(__DIR__ <> "/input.txt")
      |> String.split(["\n"])
      |> Enum.map(&Integer.parse/1)
      |> Enum.map(&elem(&1, 0))

    IO.puts("1: #{part1(numbers)}")
    IO.puts("2: #{part2(numbers)}")
  end

  def part1(numbers) do
    numbers =
      numbers
      |> Enum.with_index()
      |> mix()

    grove_coordinates(numbers)
  end

  def mix(numbers) do
    0..(length(numbers) - 1)
    |> Enum.reduce(numbers, fn file_number_index, acc ->
      list_number_index = acc |> Enum.find_index(fn {_, file_i} -> file_i == file_number_index end)

      {left, [{list_number_value, _file_i} | right]} = acc |> Enum.split(list_number_index)

      acc = left ++ right

      new_list_number_index = Integer.mod(list_number_index + list_number_value, length(acc))

      {left, right} = acc |> Enum.split(new_list_number_index)

      left ++ [{list_number_value, file_number_index}] ++ right
    end)
  end

  defp grove_coordinates(numbers) do
    i0 = numbers |> Enum.find_index(fn {v, _file_i} -> v == 0 end)
    i1000 = Integer.mod(i0 + 1000, length(numbers))
    i2000 = Integer.mod(i0 + 2000, length(numbers))
    i3000 = Integer.mod(i0 + 3000, length(numbers))

    [i1000, i2000, i3000]
    |> Enum.map(fn i -> numbers |> Enum.at(i) |> elem(0) end)
    |> Enum.sum()
  end

  def part2(numbers) do
    numbers = numbers |> Enum.map(fn x -> x * 811589153 end) |> Enum.with_index()

    numbers =
      1..10
      |> Enum.reduce(numbers, fn _round, acc ->
        mix(acc)
      end)

    grove_coordinates(numbers)
  end

end
