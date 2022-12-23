defmodule AdventOfCode.Day22.MyCubeWrapper do
  alias AdventOfCode.Day22.CubeWrapper
  @behaviour CubeWrapper

  @up {0, -1}
  @down {0, 1}
  @left {-1, 0}
  @right {1, 0}

  @impl CubeWrapper
  def wrap({x, y, c}, {a, b}) do
    side_width = 50
    rev = side_width - 1

    {{a, b}, x, y, c} = %{
      1 => %{           #     swap?
        # cur      new   reverse   reverse new_side
        # dir      dir       x        y
        @up    => {@right,      y,       x,  6},
        @down  => {@down,       x, rev - y,  3},
        @left  => {@right,      x, rev - y,  4},
        @right => {@right,rev - x,       y,  2}
      },
      2 => %{
        @up    => {@up,         x, rev - y,  6},
        @down  => {@left,       y,       x,  3},
        @left  => {@left, rev - x,       y,  1},
        @right => {@left,       x, rev - y,  5}
      },
      3 => %{
        @up    => {@up,         x, rev - y,  1},
        @down  => {@down,       x, rev - y,  5},
        @left  => {@down,       y,       x,  4},
        @right => {@up,         y,       x,  2}
      },
      4 => %{
        @up    => {@right,      y,       x,  3},
        @down  => {@down,       x, rev - y,  6},
        @left  => {@right,      x, rev - y,  1},
        @right => {@right,rev - x,       y,  5}
      },
      5 => %{
        @up    => {@up,         x, rev - y,  3},
        @down  => {@left,       y,       x,  6},
        @left  => {@left, rev - x,       y,  4},
        @right => {@left,       x, rev - y,  2}
      },
      6 => %{
        @up    => {@up,         x, rev - y,  4},
        @down  => {@down,       x, rev - y,  2},
        @left  => {@down,       y,       x,  1},
        @right => {@up,         y,       x,  5}
      }
    }[c][{a, b}]

    {{x, y, c}, {a, b}}
  end

  @impl CubeWrapper
  def side({x, y}) do
    side_width = 50

    side_map = %{
      {1, 0} => 1,
      {2, 0} => 2,
      {1, 1} => 3,
      {0, 2} => 4,
      {1, 2} => 5,
      {0, 3} => 6
    }
    |> Enum.map(fn {{i, j}, c} ->
      {{{i * side_width, (i + 1) * side_width - 1}, {j * side_width, (j + 1) * side_width - 1}}, c}
    end)
    |> Enum.into(Map.new)

    m_x = Integer.floor_div(x, side_width) * side_width
    n_x = m_x + side_width - 1
    m_y = Integer.floor_div(y, side_width) * side_width
    n_y = m_y + side_width - 1

    my_range = {{m_x, n_x}, {m_y, n_y}}

    if side_map[my_range] == nil do
      IO.puts("nil for #{x}, #{y}; #{m_x}, #{n_x}; #{m_y}, #{n_y}")
    end

    side_map[{{m_x, n_x}, {m_y, n_y}}]
  end
end
