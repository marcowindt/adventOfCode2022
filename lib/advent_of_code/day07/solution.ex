defmodule AdventOfCode.Day07.Solution do

  def run() do
    contents = File.read!(__DIR__ <> "/input.txt") |> String.split("\n")

    dirs_without_sub_dirs = make_dirs(%{}, [], contents)

    dirs =
      dirs_without_sub_dirs
      |> Enum.map(fn {dir, _files} ->
        size =
          dirs_without_sub_dirs
          |> Enum.filter(fn {dir_name, _files} -> String.starts_with?(dir_name, dir) end)
          |> Enum.reduce(0, fn {_dir_name, files}, acc -> Enum.sum(files) + acc end)

        {dir, size}
      end)
      |> Map.new()

    IO.puts("1: #{part1(dirs)}")
    IO.puts("2: #{part2(dirs)}")
  end

  def part1(dirs) do
    dirs
    |> Enum.filter(fn {_dir, size} -> size <= 100000 end)
    |> Enum.map(&elem(&1, 1))
    |> Enum.sum()
  end

  def part2(dirs) do
    needed = 30000000 - (70000000 - dirs["/"])

    dirs
    |> Enum.filter(fn {dir, size} -> size > needed && dir != "/" end)
    |> Enum.map(&elem(&1, 1))
    |> Enum.min()
  end

  defp location_name(location) do
    location
    |> Enum.reverse()
    |> Enum.join("/")
  end

  def make_dirs(tree, _location, []), do: tree

  def make_dirs(%{}, [], ["$ cd /" | commands]) do
    make_dirs(%{"/" => []}, ["/"], commands)
  end

  def make_dirs(tree, [_cur_dir | location], ["$ cd .." | commands]) do
    make_dirs(tree, location, commands)
  end

  def make_dirs(tree, location, ["$ cd " <> dir_name | commands]) do
    tree
    |> Map.merge(%{location_name([dir_name | location]) => []})
    |> make_dirs([dir_name | location], commands)
  end

  def make_dirs(tree, location, ["$ ls" | commands]) do
    make_dirs(tree, location, commands)
  end

  def make_dirs(tree, location, ["dir " <> _dir_name | commands]) do
    make_dirs(tree, location, commands)
  end

  def make_dirs(tree, location, [file | commands]) do
    [file_size, _file_name] = String.split(file, " ")
    {file_size, _remainder} = Integer.parse(file_size)

    tree
    |> Map.merge(%{location_name(location) => [file_size]}, fn _k, v1, v2 -> v1 ++ v2 end)
    |> make_dirs(location, commands)
  end

end
