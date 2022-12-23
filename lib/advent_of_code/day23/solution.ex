defmodule AdventOfCode.Day23.Solution do

  def run() do
    elves =
      File.read!(__DIR__ <> "/input.txt")
      |> String.split(["\n"])
      |> Enum.with_index()
      |> Enum.map(fn {row, y} ->
        row
        |> String.codepoints()
        |> Enum.with_index()
        |> Enum.reduce([], fn {col, x}, acc ->
          if col == "#" do
            [{x, y} | acc]
          else
            acc
          end
        end)
      end)
      |> List.flatten()
      |> Enum.map(fn elf -> {elf, true} end)
      |> Enum.into(Map.new)

    IO.puts("1: #{part1(elves)}")
    IO.puts("2: #{part2(elves)}")
  end

  def part1(elves) do
    checks = [{&can_go_north/2, {0, -1}}, {&can_go_south/2, {0, 1}}, {&can_go_west/2, {-1, 0}}, {&can_go_east/2, {1, 0}}]

    {elves, _checks} =
      1..10
      |> Enum.reduce({elves, checks}, fn _round, {acc, checks} ->
        simulate(acc, checks)
      end)

    empty_ground_tiles(elves |> Map.keys())
  end

  defp empty_ground_tiles(elves) do
    xs = elves |> Enum.map(fn {x, _y} -> x end)
    min_x = xs |> Enum.min()
    max_x = xs |> Enum.max()

    ys = elves |> Enum.map(fn {_x, y} -> y end)
    min_y = ys |> Enum.min()
    max_y = ys |> Enum.max()

    width = abs(max_x - min_x) + 1
    height = abs(max_y - min_y) + 1

    width * height - length(elves)
  end

  def simulate(elves, [check | checks] = can_go) do
    my_checks = [{&all_free/2, {0, 0}} | can_go]

    {will_go, must_stay} =
      elves
      |> Enum.reduce({%{}, %{}}, fn {{x, y} = elf, _bool}, {will_go, must_stay} ->
        new_elf =
          my_checks
          |> Enum.reduce_while(0, fn {free_check, {a, b}}, _acc ->
            if free_check.(elves, elf) do
              {:halt, {x + a, y + b}}
            else
              {:cont, {x, y}}
            end
          end)

        cond do
          Map.has_key?(must_stay, new_elf) -> {will_go, must_stay |> Map.put(new_elf, [elf | will_go[new_elf]])}
          Map.has_key?(will_go, new_elf) ->
            {stay_elf, will_go} = Map.pop(will_go, new_elf)
            {will_go, must_stay |> Map.put(new_elf, [elf, stay_elf])}
          true -> {will_go |> Map.put(new_elf, elf), must_stay}
        end
      end)

    will_go = will_go |> Map.keys()
    must_stay = must_stay |> Map.values() |> List.flatten()

    {will_go ++ must_stay |> Enum.map(fn elf -> {elf, true} end) |> Enum.into(Map.new), checks ++ [check]}
  end

  def all_free(elves, {x, y} = _elf) do
    eight_adjacent = [
      {x - 1, y - 1}, {x, y - 1}, {x + 1, y - 1},
      {x - 1, y},                 {x + 1, y},
      {x - 1, y + 1}, {x, y + 1}, {x + 1, y + 1}
    ]
    is_free(elves, eight_adjacent)
  end

  def can_go_north(elves, {x, y} = _elf) do
    northern_spots = [{x - 1, y - 1}, {x, y - 1}, {x + 1, y - 1}]
    is_free(elves, northern_spots)
  end

  def can_go_south(elves, {x, y} = _elf) do
    southern_spots = [{x - 1, y + 1}, {x, y + 1}, {x + 1, y + 1}]
    is_free(elves, southern_spots)
  end

  def can_go_west(elves, {x, y} = _elf) do
    western_spots = [{x - 1, y - 1}, {x - 1, y}, {x - 1, y + 1}]
    is_free(elves, western_spots)
  end

  def can_go_east(elves, {x, y} = _elf) do
    eastern_spots = [{x + 1, y - 1}, {x + 1, y}, {x + 1, y + 1}]
    is_free(elves, eastern_spots)
  end

  defp is_free(elves, spots) do
    spots
    |> Enum.reduce_while(true, fn spot, _acc ->
      if Map.has_key?(elves, spot) do
        {:halt, false}
      else
        {:cont, true}
      end
    end)
  end

  def print_elves(%{} = elves) do
    xs = elves |> Enum.map(fn {x, _y} -> x end)
    min_x = xs |> Enum.min()
    max_x = xs |> Enum.max()

    ys = elves |> Enum.map(fn {_x, y} -> y end)
    min_y = ys |> Enum.min()
    max_y = ys |> Enum.max()

    min_y..max_y
    |> Enum.map(fn y ->
      min_x..max_x
      |> Enum.map(fn x ->
        if Map.has_key?(elves, {x, y}) do
          "#"
        else
          "."
        end
      end)
      |> Enum.join()
    end)
    |> Enum.join("\n")
    |> IO.puts()
  end

  def part2(elves) do
    checks = [{&can_go_north/2, {0, -1}}, {&can_go_south/2, {0, 1}}, {&can_go_west/2, {-1, 0}}, {&can_go_east/2, {1, 0}}]

    1..10000
    |> Enum.reduce_while({elves, checks}, fn round, {acc, checks} ->
      prev_acc = acc
      {acc, checks} = simulate(acc, checks)

      if acc == prev_acc do
        {:halt, round}
      else
        {:cont, {acc, checks}}
      end
    end)
  end

end
