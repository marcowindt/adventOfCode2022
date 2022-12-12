defmodule AdventOfCode.Day12.Solution do
  alias PriorityQueue

  @chars "abcdefghijklmnopqrstuvwxyz" |> String.codepoints |> Enum.with_index() |> Enum.reduce(%{}, fn {c, i}, acc -> acc |> Map.merge(%{c => i}) end)

  def run() do
    contents =
      File.read!(__DIR__ <> "/input.txt")
      |> String.split(["\n"])
      |> Enum.map(&String.codepoints/1)

    graph = gen_graph(contents)

    IO.puts("1: #{part1(graph)}")
    IO.puts("2: #{part2(graph)}")
  end

  def gen_graph(heightmap) do
    0..(length(heightmap) - 1)
    |> Enum.reduce(%{}, fn y, acc_og ->
      0..(length(heightmap |> Enum.at(0)) - 1)
      |> Enum.reduce(%{}, fn x, acc ->
        c = heightmap |> Enum.at(y) |> Enum.at(x)

        neighbours =
          [{x, y - 1}, {x + 1, y}, {x, y + 1}, {x - 1, y}]
          |> Enum.reduce([], fn {a, b}, acc ->
            d = heightmap |> heightmap_get(c, {a, b})
            case d do
              nil -> acc
              _ -> [d | acc]
            end
          end)

        acc |> Map.put({x, y}, neighbours)
      end)
      |> Map.merge(acc_og)
    end)
  end

  def heightmap_get(heightmap, c, {x, y}) do
    cond do
      x >= 0 && y >= 0 && x < length(heightmap |> Enum.at(0)) && y < length(heightmap) ->
        d = heightmap |> Enum.at(y) |> Enum.at(x)
        if (abs(char_height(c) - char_height(d)) <= 1 || char_height(d) < char_height(c)) do
          {{x, y}, d}
        else
          nil
        end
      true -> nil
    end
  end

  def char_height(c) do
    case c do
      "S" -> @chars["a"]
      "E" -> @chars["z"]
      _ -> @chars[c]
    end
  end

  def strip_chars(graph) do
    graph
    |> Enum.reduce(%{}, fn {vertex, edges}, acc ->
      acc
      |> Map.merge(%{vertex => edges |> Enum.map(fn {{x, y}, _c} -> {x, y} end)})
    end)
  end

  def part1(graph) do
    vertices = Map.values(graph) |> Enum.concat()
    {source, "S"} = vertices |> Enum.find(fn {{_x, _y}, p} -> p == "S" end)
    {sink, "E"}   = vertices |> Enum.find(fn {{_x, _y}, p} -> p == "E" end)
    {cost, _path} = dijkstra(graph |> strip_chars(), source, sink)
    cost
  end

  def manhattan({x, y}, {a, b}), do: abs(x - a) + abs(y - b)

  def dijkstra(graph, source, sink) do
    shortest_path(graph, [{0, [source]}] |> Enum.into(PriorityQueue.new()), sink, %{source => true})
  end

  def shortest_path(_graph, %PriorityQueue{size: 0}, _sink, _visited), do: {0, []}

  def shortest_path(graph, %PriorityQueue{} = pq, sink, visited) do
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

      shortest_path(graph, new_paths, sink, visited)
    end
  end

  def part2(graph) do
    vertices = Map.values(graph) |> Enum.concat()

    all_a =
      vertices
      |> Enum.reduce([], fn {point, c}, acc ->
        case c do
          "a" -> [point | acc]
          _ -> acc
        end
      end)

    {sink, "E"} = vertices |> Enum.find(fn {{_x, _y}, p} -> p == "E" end)
    graph = strip_chars(graph)

    all_a
    |> Enum.reduce(99999, fn source, acc ->
      {cost, _path} = dijkstra(graph, source, sink)

      cond do
        cost != 0 && cost < acc -> cost
        true -> acc
      end
    end)
  end
end
