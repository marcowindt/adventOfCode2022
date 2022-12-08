defmodule AdventOfCode.Day08.Solution do

  def run() do
    trees =
      File.read!(__DIR__ <> "/input.txt")
      |> String.split("\n")
      |> Enum.map(fn trees ->
        trees
        |> String.codepoints()
        |> Enum.map(fn tree ->
          tree
          |> Integer.parse()
          |> elem(0)
        end)
      end)

    seert =
      trees
      |> Enum.zip_with(& &1)

    IO.puts("1: #{part1(trees, seert)}")
    IO.puts("2: #{part2(trees, seert)}")
  end

  def part1(trees, seert) do
    until = length(trees) - 2

    1..until
    |> Enum.reduce(0, fn row, acc ->
      trees_row =
        trees
        |> Enum.at(row)

      1..until
      |> Enum.reduce(0, fn column, acc ->
        trees_column =
          seert
          |> Enum.at(column)

        tree =
          trees_row
          |> Enum.at(column)

        if Enum.slice(trees_row, 0..(column - 1)) |> visible(tree)
        || Enum.slice(trees_row, (column + 1)..(until + 1)) |> visible(tree)
        || Enum.slice(trees_column, 0..(row - 1)) |> visible(tree)
        || Enum.slice(trees_column, (row + 1)..(until + 1)) |> visible(tree) do
           acc + 1
         else
          acc
         end
      end)
      |> Kernel.+(acc)
    end)
    |> Kernel.+((length(trees) * 4) - 4)
  end

  def visible(blocking_trees, tree) do
    cond do
      length(blocking_trees) == 0 -> true
      Enum.max(blocking_trees) < tree -> true
      true -> false
    end
  end

  def part2(trees, seert) do
    until = length(trees) - 2

    1..until
    |> Enum.reduce(0, fn row, acc ->
      trees_row =
        trees
        |> Enum.at(row)

      scenic_score =
        1..until
        |> Enum.reduce(0, fn column, acc ->
          trees_column =
            seert
            |> Enum.at(column)

          tree =
            trees_row
            |> Enum.at(column)

          left =
            Enum.slice(trees_row, 0..(column - 1))
            |> Enum.reverse()
            |> view(tree)

          right =
            Enum.slice(trees_row, (column + 1)..(until + 1))
            |> view(tree)

          top =
            Enum.slice(trees_column, 0..(row - 1))
            |> Enum.reverse()
            |> view(tree)

          bottom =
            Enum.slice(trees_column, (row + 1)..(until + 1))
            |> view(tree)

          scenic_score = top * left * bottom * right

          if scenic_score > acc, do: scenic_score, else: acc
        end)
      if scenic_score > acc, do: scenic_score, else: acc
    end)
  end

  def view(trees, tree) do
    trees
    |> Enum.reduce_while(0, fn t, acc ->
      if t < tree, do: {:cont, acc + 1}, else: {:halt, acc + 1}
    end)
  end

end
