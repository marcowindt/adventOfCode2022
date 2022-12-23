defmodule AdventOfCode.Day21.Solution do

  def run() do
    monkeys =
      File.read!(__DIR__ <> "/input.txt")
      |> String.split(["\n"])
      |> Enum.map(fn monkey_operation ->
        [monkey, operation] =
          monkey_operation
          |> String.split(": ")

        if operation |> String.split(" ") |> length() == 3 do
          [left, operation, right] = operation |> String.split(" ")
          # operation monkey
          {monkey, {left, operation, right}}
        else
          # yell monkey
          {monkey, Integer.parse(operation) |> elem(0)}
        end
      end)
      |> Enum.into(Map.new)

    IO.puts("1: #{part1(monkeys)}")
    IO.puts("2: #{part2(monkeys)}")
  end

  def part1(monkeys) do
    calc(monkeys, monkeys["root"])
  end

  def calc(_monkeys, _x, _operations \\ %{"+" => &Kernel.+/2, "-" => &Kernel.-/2, "/" => &Kernel.//2, "*" => &Kernel.*/2})
  def calc(_monkeys, x, _operations) when is_integer(x), do: x

  def calc(monkeys, {left, operation, right}, operations) do
    left = calc(monkeys, monkeys[left])
    right = calc(monkeys, monkeys[right])

    operations[operation].(left, right)
  end

  def part2(monkeys) do
    monkeys = monkeys |> Map.put("root", {monkeys["root"] |> elem(0), "=", monkeys["root"] |> elem(2)})
    monkeys = monkeys |> Map.put("humn", :x)

    should_equal = calc(monkeys, monkeys[monkeys["root"] |> elem(2)])

    print_calc(monkeys, monkeys["root"])
    reverse_calc(monkeys, monkeys[monkeys["root"] |> elem(0)], should_equal)
  end

  def print_calc(_monkeys, x) when is_integer(x), do: "#{x}"
  def print_calc(_monkeys, :x), do: :x

  def print_calc(monkeys, {left, operation, right}) do
    left = print_calc(monkeys, monkeys[left])
    right = print_calc(monkeys, monkeys[right])

    "(#{left}) #{operation} (#{right})"
  end

  def contains_human(_monkeys, :x), do: true
  def contains_human(_monkeys, x) when is_integer(x), do: false

  def contains_human(monkeys, {left, _operation, right}) do
    contains_human(monkeys, monkeys[left]) || contains_human(monkeys, monkeys[right])
  end

  def reverse_calc(_monkeys, :x, result), do: result

  def reverse_calc(monkeys, {left, "+", right}, result) do
    if contains_human(monkeys, monkeys[left]) do
      reverse_calc(monkeys, monkeys[left], result - calc(monkeys, monkeys[right]))
    else
      reverse_calc(monkeys, monkeys[right], result - calc(monkeys, monkeys[left]))
    end
  end

  def reverse_calc(monkeys, {left, "-", right}, result) do
    if contains_human(monkeys, monkeys[left]) do
      reverse_calc(monkeys, monkeys[left], result + calc(monkeys, monkeys[right]))
    else
      reverse_calc(monkeys, monkeys[right], -result + calc(monkeys, monkeys[left]))
    end
  end

  def reverse_calc(monkeys, {left, "*", right}, result) do
    if contains_human(monkeys, monkeys[left]) do
      reverse_calc(monkeys, monkeys[left], result / calc(monkeys, monkeys[right]))
    else
      reverse_calc(monkeys, monkeys[right], result / calc(monkeys, monkeys[left]))
    end
  end

  def reverse_calc(monkeys, {left, "/", right}, result) do
    if contains_human(monkeys, monkeys[left]) do
      reverse_calc(monkeys, monkeys[left], result * calc(monkeys, monkeys[right]))
    else
      reverse_calc(monkeys, monkeys[right], calc(monkeys, monkeys[left]) / result)
    end
  end

end
