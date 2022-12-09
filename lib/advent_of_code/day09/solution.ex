defmodule AdventOfCode.Day09.Solution do

  def run() do
    steps =
      File.read!(__DIR__ <> "/input.txt")
      |> String.split(["\n", " "])
      |> Enum.chunk_every(2)
      |> Enum.map(fn [x, y] -> {x, Integer.parse(y) |> elem(0)} end)

    trail_1 = part1(steps)

    IO.puts("1: #{trail_1 |> Enum.uniq() |> length()}")
    IO.puts("2: #{trail_1 |> part2() |> Enum.uniq() |> length()}")
  end

  def part1(steps) do
    move(steps)
  end

  def move( _steps \\ [], _head \\ {0, 0}, _tail \\ {0, 0}, _went \\ [])
  def move([], _head, _tail, went), do: went
  def move([{_direction, 0} | steps], head, tail, went), do: move(steps, head, tail, went)

  def move([{"R", x} | steps], {hx, hy}, {tx, ty}, went) do
    {hx, hy} = {hx + 1, hy}
    {tx, ty} = new_tail({hx, hy}, {tx, ty})
    move([{"R", x - 1} | steps], {hx, hy}, {tx, ty}, [{tx, ty} | went])
  end

  def move([{"U", x} | steps], {hx, hy}, {tx, ty}, went) do
    {hx, hy} = {hx, hy + 1}
    {tx, ty} = new_tail({hx, hy}, {tx, ty})
    move([{"U", x - 1} | steps], {hx, hy}, {tx, ty}, [{tx, ty} | went])
  end

  def move([{"L", x} | steps], {hx, hy}, {tx, ty}, went) do
    {hx, hy} = {hx - 1, hy}
    {tx, ty} = new_tail({hx, hy}, {tx, ty})
    move([{"L", x - 1} | steps], {hx, hy}, {tx, ty}, [{tx, ty} | went])
  end

  def move([{"D", x} | steps], {hx, hy}, {tx, ty}, went) do
    {hx, hy} = {hx, hy - 1}
    {tx, ty} = new_tail({hx, hy}, {tx, ty})
    move([{"D", x - 1} | steps], {hx, hy}, {tx, ty}, [{tx, ty} | went])
  end

  defp distance({hx, hy}, {tx, ty}), do: round(:math.floor(:math.sqrt(:math.pow(hx - tx, 2) + :math.pow(hy - ty, 2))))

  defp new_tail_c(hc, tc) when abs(hc - tc) >= 1 do
    if hc > tc do
      tc + 1
    else
      tc - 1
    end
  end
  defp new_tail_c(_hc, tc), do: tc

  defp new_tail({hx, hy}, {tx, ty}) do
    if distance({hx, hy}, {tx, ty}) > 1 do
      {new_tail_c(hx, tx), new_tail_c(hy, ty)}
    else
      {tx, ty}
    end
  end

  def part2(trail) do
    2..9
    |> Enum.reduce(trail |> Enum.reverse(), fn _, acc -> follow(acc) |> Enum.reverse() end)
  end

  def follow(_trail, _tail \\ {0, 0}, _went \\ [])
  def follow([], _tail, went), do: went
  def follow([{hx, hy} | trail], {tx, ty}, went) do
    {tx, ty} = new_tail({hx, hy}, {tx, ty})
    follow(trail, {tx, ty}, [{tx, ty} | went])
  end

  def print(head, tail, size \\ 6) do
    0..(size - 2)
    |> Enum.map(fn y ->
      line = 0..(size - 1)
        |> Enum.map(fn x ->
          cond do
            head == {x, y} -> "H"
            tail == {x, y} -> "T"
            {0, 0} == {x, y} -> "s"
            true -> "."
          end
        end)
        |> Enum.join()
      line <> "\n"
    end)
    |> Enum.reverse()
    |> IO.puts()
  end

  def print_trail(went, size \\ 30) do
    -(size - 2)..(size - 2)
    |> Enum.map(fn y ->
      line = -(size - 1)..(size - 1)
        |> Enum.map(fn x ->
          cond do
            {0, 0} == {x, y} -> "s"
            Enum.find(went, {0, 0}, fn p -> p == {x, y} end) == {x, y} -> "#"
            true -> "."
          end
        end)
        |> Enum.join()
      line <> "\n"
    end)
    |> Enum.reverse()
    |> IO.puts()

    went
  end
end
