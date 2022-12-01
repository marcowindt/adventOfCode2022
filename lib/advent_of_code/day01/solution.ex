defmodule AdventOfCode.Day01.Solution do

  def run() do
    contents = File.read!(__DIR__ <> "/input.txt")

    calories =
      contents
      |> String.split("\n\n")
      |> Enum.map(fn elf ->
        elf
        |> String.split("\n")
        |> Enum.map(fn calorie ->
          {calorie, _remainder} = Integer.parse(calorie)
          calorie
        end)
        |> Enum.sum()
      end)
      |> Enum.sort()
      |> Enum.reverse()

    IO.puts("1: #{calories |> Enum.max()}")
    IO.puts("2: #{calories |> Enum.take(3) |> Enum.sum()}")
  end
end
