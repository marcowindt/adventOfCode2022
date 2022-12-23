defmodule AdventOfCode.Day16.Solution do
  alias PriorityQueue

  def run() do
    contents =
      File.read!(__DIR__ <> "/input.txt")
      |> String.split(["\n"])
      |> Enum.map(fn row ->
        row = Regex.run(~r/Valve ([A-Z][A-Z]) has flow rate=(?<rate>[-]?\d*); tunnels? leads? to valves? (?<neighbours>.*)/, row) |> Enum.drop(1)
        [valve | row] = row
        [rate | [row]] = row
        rate = Integer.parse(rate) |> elem(0)

        {valve, rate, String.split(row, ", ")}
      end)

    valves =
      contents
      |> Enum.reduce(%{}, fn {valve, rate, _neighbours}, acc ->
        acc |> Map.put(valve, rate)
      end)

    graph =
      contents
      |> Enum.reduce(%{}, fn {valve, rate, neighbours}, acc ->
        neighbours =
          neighbours
          |> Enum.map(fn n_valve ->
            {n_valve, Map.get(valves, n_valve)}
          end)

        acc |> Map.put({valve, rate}, neighbours)
      end)

    interesting_valves = valves |> Enum.filter(fn {_n, rate} -> rate > 0 end)
    interesting_valves = [{"AA", 0} | interesting_valves]

    valve_graph =
      interesting_valves
      |> Enum.reduce(%{}, fn v, acc ->
        neighbours =
          interesting_valves -- [v]
          |> Enum.map(fn valve ->
            {cost, _path} = dijkstra(graph, v, valve)

            {valve, cost + 1}
          end)
          |> Enum.filter(fn {valve, _cost} -> valve != {"AA", 0} end)

        acc |> Map.put(v, neighbours)
      end)

    {max_flow, best_path} = part1(interesting_valves, valve_graph)

    IO.puts("1: #{max_flow}")
    IO.puts("2: #{part2(interesting_valves, valve_graph, best_path)}")
  end

  def part1(interesting_valves, valve_graph) do
    interesting_valves -- [{"AA", 0}]
    |> Enum.map(fn valve ->
      possibles = Enum.sort(shortest_path(valve_graph, [{0, 0, 0, [{"AA", 0}]}], valve, 30), :desc)
      hd(possibles)
    end)
    |> Enum.max()
  end

  def dijkstra(graph, source, sink) do
    dijkstra_shortest_path(graph, [{0, [source]}] |> Enum.into(PriorityQueue.new()), sink, %{source => true})
  end

  def dijkstra_shortest_path(_graph, %PriorityQueue{size: 0}, _sink, _visited), do: {0, []}

  def dijkstra_shortest_path(graph, %PriorityQueue{} = pq, sink, visited) do
    {{cost, [node | _] = path}, pq} = PriorityQueue.pop(pq)

    if node == sink do
      {cost, Enum.reverse(path)}
    else
      new_nodes =
        Map.get(graph, node)
        |> Enum.filter(&(not Map.has_key?(visited, &1)))

      visited =
        new_nodes
        |> Enum.reduce(visited, fn n, acc -> acc |> Map.put(n, true) end)

      new_paths =
        new_nodes
        |> Enum.map(fn new_node -> {cost + 1, [new_node | path]} end)
        |> Enum.reduce(pq, fn p, acc -> PriorityQueue.put(acc, p) end)

        dijkstra_shortest_path(graph, new_paths, sink, visited)
    end
  end

  def calc_pressure(_valve_graph, minute, flow, {_prev_valve, _prev_rate}, []) do
    (26 - minute) * flow
  end

  def calc_pressure(valve_graph, minute, flow, {prev_valve, prev_rate}, [{valve, _rate} | path]) do
    ns = Map.get(valve_graph, {prev_valve, prev_rate}) |> Enum.filter(fn {{v, _r}, _c} -> valve == v end)

    if length(ns) == 0 || minute > 26 do
      0
    else
      {{v, r}, c} = hd(ns)

      c * flow + calc_pressure(valve_graph, minute + c, flow + r, {v, r}, path)
    end
  end

  def shortest_path(_graph, [], _end, _max_time), do: [{0, []}]

  def shortest_path(graph, [{cost, minute, flow, [{_valve, _rate} = sink | _] = path} | paths], sink, max_time) do
    [{cost + (max_time - minute) * flow, Enum.reverse(path)}] ++ shortest_path(graph, paths, sink, max_time)
  end

  def shortest_path(graph, [{cost, minute, flow, [node | _] = path} | paths], sink, max_time) do
    if minute > 30 do
      shortest_path(graph, paths, sink, max_time)
    else
      new_nodes = Map.get(graph, node) |> Enum.filter(fn {{v, r}, _c} -> not Enum.member?(path, {v, r}) end)

      new_paths =
        new_nodes
        |> Enum.map(fn {{v, r}, c} ->
          {cost + c * flow, minute + c, flow + r, [{v, r} | path]}
        end)

      shortest_path(graph, Enum.sort(paths ++ new_paths, :desc), sink, max_time)
    end
  end

  def part2(interesting_valves, valve_graph, best_path) do
    all_paths =
      interesting_valves -- [{"AA", 0}]
      |> Enum.reduce([], fn valve, acc ->
        possibles = Enum.sort(shortest_path(valve_graph, [{0, 0, 0, [{"AA", 0}]}], valve, 26), :desc)

        acc ++ possibles
      end)

    options =
      all_paths
      |> Enum.reduce([], fn {pressure, path}, acc_og ->
        other_path = best_path -- path

        other_pressure = calc_pressure(valve_graph, 0, 0, {"AA", 0}, other_path)

        [{pressure + other_pressure, path, other_path} | acc_og]
      end)

    Enum.max(options)
    |> elem(0)
  end

end
