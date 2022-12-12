defmodule AdventOfCode.Day11.Solution do

  def run() do
    monkeys =
      File.read!(__DIR__ <> "/input.txt")
      |> String.split("\n\n")
      |> Enum.with_index()
      |> Enum.reduce(%{}, fn {monkey, i}, acc ->
        acc
        |> Map.merge(%{i => parse_monkey(i, monkey)})
      end)

    IO.puts("1: #{part1(monkeys)}")
    IO.puts("2: #{part2(monkeys)}")
  end

  defp parse_monkey(i, monkey) do
    monkey =
      monkey
      |> String.split("\n")
      |> Enum.drop(1)

    starting_items =
      monkey
      |> Enum.at(0)
      |> String.split("  Starting items: ")
      |> List.last()
      |> String.split(", ")
      |> Enum.map(fn item -> Integer.parse(item) |> elem(0) end)

    [operation, argument] =
      monkey
      |> Enum.at(1)
      |> String.split("  Operation: new = old ")
      |> List.last()
      |> String.split(" ")
      |> Enum.map(fn x ->
        x
        |> case do
          "+" -> &Kernel.+/2
          "*" -> &Kernel.*/2
          _ -> x
        end
      end)

    argument = case argument do
      "old" -> :old
      a -> Integer.parse(a) |> elem(0)
    end

    divisible_by =
      monkey
      |> Enum.at(2)
      |> String.split("  Test: divisible by ")
      |> List.last()
      |> Integer.parse()
      |> elem(0)

    positive_monkey =
      monkey
      |> Enum.at(3)
      |> String.split("    If true: throw to monkey ")
      |> List.last()
      |> Integer.parse()
      |> elem(0)

    negative_monkey =
      monkey
      |> Enum.at(4)
      |> String.split("    If false: throw to monkey ")
      |> List.last()
      |> Integer.parse()
      |> elem(0)

    %{
      monkey: i,
      items: starting_items,
      operation: operation,
      argument: argument,
      divisible_by: divisible_by,
      positive_monkey: positive_monkey,
      negative_monkey: negative_monkey,
      inspected: 0
    }
  end

  def part1(monkeys) do
    common_divisor =
      monkeys
      |> Enum.reduce(1, fn {_i, monkey}, acc -> monkey[:divisible_by] * acc end)

    1..20
    |> Enum.reduce(monkeys, fn _round, acc ->
      0..(map_size(monkeys) - 1)
      |> Enum.reduce(acc, fn i, ms ->
        minspect(ms[i], ms, common_divisor, 3)
      end)
    end)
    |> Map.values()
    |> Enum.sort(&(&1.inspected > &2.inspected))
    |> Enum.take(2)
    |> Enum.reduce(1, fn m, acc ->
      acc * m[:inspected]
    end)
  end

  def worry(item, op, arg) when is_atom(arg), do: op.(item, item)
  def worry(item, op, arg) when is_integer(arg), do: op.(item, arg)

  def minspect(%{items: []} = _monkey, monkeys, _common_divisor, _divide_by), do: monkeys

  def minspect(%{
    monkey: i,
    items: [item | items],
    operation: op,
    argument: arg,
    divisible_by: divisible_by,
    positive_monkey: pm,
    negative_monkey: nm,
    inspected: inspected} = monkey,
    monkeys,
    common_divisor,
    divide_by
  )
  do
    monkey =
      monkey
      |> Map.put(:inspected, inspected + 1)
      |> Map.put(:items, items)

    w = rem(Integer.floor_div(worry(item, op, arg), divide_by), common_divisor)

    monkeys =
      monkeys
      |> Map.put(i, monkey)

    if rem(w, divisible_by) == 0 do
      minspect(monkey, Map.put(monkeys, pm, Map.merge(monkeys[pm], %{items: [w]}, fn _k, v1, v2 -> v1 ++ v2 end)), common_divisor, divide_by)
    else
      minspect(monkey, Map.put(monkeys, nm, Map.merge(monkeys[nm], %{items: [w]}, fn _k, v1, v2 -> v1 ++ v2 end)), common_divisor, divide_by)
    end
  end

  def part2(monkeys) do
    common_divisor =
      monkeys
      |> Enum.reduce(1, fn {_i, monkey}, acc -> monkey[:divisible_by] * acc end)

    1..10000
    |> Enum.reduce(monkeys, fn _round, acc ->
      0..(map_size(monkeys) - 1)
      |> Enum.reduce(acc, fn i, ms ->
        minspect(ms[i], ms, common_divisor, 1)
      end)
    end)
    |> Map.values()
    |> Enum.sort(&(&1.inspected > &2.inspected))
    |> Enum.take(2)
    |> Enum.reduce(1, fn m, acc ->
      acc * m[:inspected]
    end)
  end
end
