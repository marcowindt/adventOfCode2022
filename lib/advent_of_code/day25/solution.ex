defmodule AdventOfCode.Day25.Solution do

  def run() do
    contents =
      File.read!(__DIR__ <> "/input.txt")
      |> String.split(["\n"])
      |> Enum.map(fn snafu ->
        snafu
        |> String.codepoints()
        |> Enum.reverse()
        |> Enum.with_index()
        |> Enum.map(fn {s, i} ->
          case s do
            "0" -> {0, i}
            "1" -> {1, i}
            "2" -> {2, i}
            "-" -> {-1, i}
            "=" -> {-2, i}
          end
        end)
      end)

    IO.puts("1: #{part1(contents)}")
    IO.puts("2: #{part2()}")
  end

  def part1(contents) do
    contents
    |> Enum.reduce(0, fn snafu, a ->
      decimal =
        snafu
        |> Enum.reduce(0, fn {s, i}, acc ->
          acc + s * :math.pow(5, i)
        end)

      a + decimal
    end)
    |> round()
    |> Integer.digits(5)
    |> Enum.reverse()
    |> snafu()
  end

  def snafu(_number_list, _result \\ "")
  def snafu([], result), do: String.reverse(result)
  def snafu([x | []], result) do
    cond do
      x <= 2 -> snafu([], result <> "#{x}")
      x == 3 -> snafu([], result <> "=1")
      x == 4 -> snafu([], result <> "-1")
      x == 5 -> snafu([], result <> "01")
    end
  end

  def snafu([x | [y | rest]], result) do
    cond do
      x <= 2 -> snafu([y | rest], result <> "#{x}")
      x == 3 -> snafu([y + 1 | rest], result <> "=")
      x == 4 -> snafu([y + 1 | rest], result <> "-")
      x == 5 -> snafu([y + 1 | rest], result <> "0")
    end
  end

  def part2() do
    stars = 1..49 |> Enum.map(fn _start -> "⭐" end) |> Enum.join()
    """
    🎄 🌟 Merry Christmas 🌟 🎄

    Start blending:
    #{stars}

    See you next year!
    """
  end

end
