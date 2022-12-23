defmodule AdventOfCode.Day19.Solution do
  def run() do
    blueprints =
      File.read!(__DIR__ <> "/input.txt")
      |> String.split(["\n"])
      |> Enum.reduce(%{}, fn blueprint, acc ->
        [blueprint, ore_robot_cost_ore, clay_robot_cost_ore, obsidian_robot_cost_ore, obsidian_robot_cost_clay, geode_robot_cost_ore, geode_robot_cost_obsidian] =
          Regex.run(~r/Blueprint ?(\d*): Each ore robot costs ?(\d*) ore\. Each clay robot costs ?(\d*) ore\. Each obsidian robot costs ?(\d*) ore and ?(\d*) clay\. Each geode robot costs ?(\d*) ore and ?(\d*) obsidian\./, blueprint)
          |> Enum.drop(1)
          |> Enum.map(&Integer.parse/1)
          |> Enum.map(&elem(&1, 0))

        acc |> Map.put(blueprint, %{
          ore_robot: [{:ore, ore_robot_cost_ore}],
          clay_robot: [{:ore, clay_robot_cost_ore}],
          obsidian_robot: [{:ore, obsidian_robot_cost_ore}, {:clay, obsidian_robot_cost_clay}],
          geode_robot: [{:ore, geode_robot_cost_ore}, {:obsidian, geode_robot_cost_obsidian}]
        })
      end)

    IO.puts("1: #{part1(blueprints)}")
    IO.puts("2: #{part2(blueprints)}")
  end

  def part1(blueprints) do
    blueprints
    |> Map.map(fn {_i, blueprint} ->
      try_blueprint(blueprint)
    end)
    |> Enum.map(fn {i, v} -> i * v end)
    |> Enum.sum()
  end

  def try_blueprint(blueprint, until \\ 24) do
    states = simulate(blueprint, %{{{0, 0, 0, 0}, {1, 0, 0, 0}} => 1}, 1, until)

    states
    |> Map.keys()
    |> Enum.reduce(0, fn {{_ore, _clay, _obsidian, geode}, _robots}, acc -> if geode > acc, do: geode, else: acc end)
  end

  def simulate(blueprint, states, minute \\ 1, until \\ 24) do
    if minute > until do
      states
    else
      max_geode_so_far = Map.keys(states) |> Enum.reduce(0, fn {{_ore, _clay, _obsidian, geode}, _robots}, acc -> if geode > acc, do: geode, else: acc end)

      max_obsidian = blueprint[:geode_robot][:obsidian]
      max_clay = blueprint[:obsidian_robot][:clay]
      max_ore = [blueprint[:geode_robot][:ore], blueprint[:obsidian_robot][:ore], blueprint[:clay_robot][:ore], blueprint[:ore_robot][:ore]] |> Enum.max()

      states = states |> Map.reject(fn {_state, m} -> m + 1 < minute end)

      states =
        states
        |> Map.keys()
        |> Enum.reduce(states, fn {{ore, clay, obsidian, geode} = resources, {ore_r, clay_r, obsidian_r, geode_r}} = state, acc_og ->
          if geode + geode_r < max_geode_so_far || obsidian_r > max_obsidian || clay_r > max_clay || ore_r > max_ore do
            {_val, acc_og} = acc_og |> Map.pop(state)
            acc_og
          else
            [
              {true, {{ore + ore_r, clay + clay_r, obsidian + obsidian_r, geode + geode_r}, {ore_r, clay_r, obsidian_r, geode_r}}},
              {can_make(:geode_robot, blueprint, resources), {{ore - blueprint[:geode_robot][:ore] + ore_r, clay + clay_r, obsidian - blueprint[:geode_robot][:obsidian] + obsidian_r, geode + geode_r}, {ore_r, clay_r, obsidian_r, geode_r + 1}}},
              {can_make(:obsidian_robot, blueprint, resources) && not can_make(:geode_robot, blueprint, resources), {{ore - blueprint[:obsidian_robot][:ore] + ore_r, clay - blueprint[:obsidian_robot][:clay] + clay_r, obsidian + obsidian_r, geode + geode_r}, {ore_r, clay_r, obsidian_r + 1, geode_r}}},
              {can_make(:clay_robot, blueprint, resources) && not can_make(:geode_robot, blueprint, resources), {{ore - blueprint[:clay_robot][:ore] + ore_r, clay + clay_r, obsidian + obsidian_r, geode + geode_r}, {ore_r, clay_r + 1, obsidian_r, geode_r}}},
              {can_make(:ore_robot, blueprint, resources) && not can_make(:geode_robot, blueprint, resources) && not can_make(:obsidian_robot, blueprint, resources), {{ore - blueprint[:ore_robot][:ore] + ore_r, clay + clay_r, obsidian + obsidian_r, geode + geode_r}, {ore_r + 1, clay_r, obsidian_r, geode_r}}}
            ]
            |> Enum.reduce(acc_og, fn {possible_to_make, new_state}, acc ->
              cond do
                Map.get(acc, new_state, until) < minute ->
                  {_val, acc} = acc |> Map.pop!(new_state)
                  acc
                possible_to_make ->
                  acc |> Map.put(new_state, minute)
                true ->
                  acc
              end
            end)
          end
        end)

      simulate(blueprint, states, minute + 1, until)
    end
  end

  def can_make(:geode_robot, blueprint, {ore, _clay, obsidian, _geode}) do
    blueprint[:geode_robot][:ore] <= ore && blueprint[:geode_robot][:obsidian] <= obsidian
  end

  def can_make(:obsidian_robot, blueprint, {ore, clay, _obsidian, _geode}) do
    blueprint[:obsidian_robot][:ore] <= ore && blueprint[:obsidian_robot][:clay] <= clay
  end

  def can_make(:clay_robot, blueprint, {ore, _clay, _obsidian, _geode}) do
    blueprint[:clay_robot][:ore] <= ore
  end

  def can_make(:ore_robot, blueprint, {ore, _clay, _obsidian, _geode}) do
    blueprint[:ore_robot][:ore] <= ore
  end

  def part2(blueprints) do
    1..3
    |> Enum.map(fn i -> try_blueprint(blueprints[i], 32) end)
    |> Enum.product()
  end

end
