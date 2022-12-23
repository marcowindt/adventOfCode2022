defmodule AdventOfCode.Day22.ExampleCubeWrapper do
  alias AdventOfCode.Day22.CubeWrapper
  @behaviour CubeWrapper

  @up {0, -1}
  @down {0, 1}
  @left {-1, 0}
  @right {1, 0}

  @impl CubeWrapper
  @spec wrap({number, number, number}, {number, number}) :: {{number, number, number}, {number, number}}
  def wrap({x, y, c}, {a, b}) do
    side_width = 4
    rev = side_width - 1

    {{a, b}, x, y, c} = %{
      1 => %{           #     swap?
        # cur      new   reverse   reverse new_side
        # dir      dir       x        y
        @up    => {@up,   rev - x,       y,  2},
        @down  => {@down,       x, rev - y,  4},
        @left  => {@down,       y,       x,  3},
        @right => {@left,       x, rev - y,  6}
      },
      2 => %{
        @up    => {@down, rev - x,       y,  1},
        @down  => {@up,   rev - x,       y,  5},
        @left  => {@up,   rev - y, rev - x,  6},
        @right => {@right,rev - x,       y,  3}
      },
      3 => %{
        @up    => {@right,      y,       x,  1},
        @down  => {@right,rev - y, rev - x,  5},
        @left  => {@left, rev - x,       y,  2},
        @right => {@right,rev - x,       y,  4}
      },
      4 => %{
        @up    => {@up,         x, rev - y,  1},
        @down  => {@down,       x, rev - y,  5},
        @left  => {@left, rev - x,       y,  3},
        @right => {@down, rev - y, rev - x,  6}
      },
      5 => %{
        @up    => {@up,         x, rev - y,  4},
        @down  => {@up,   rev - x,       y,  2},
        @left  => {@down,       y,       x,  3},
        @right => {@left,       x, rev - y,  6}
      },
      6 => %{
        @up    => {@left, rev - y, rev - x,  4},
        @down  => {@right,rev - y, rev - x,  2},
        @left  => {@left, rev - x,       y,  5},
        @right => {@left,       x, rev - y,  1}
      }
    }[c][{a, b}]

    {{x, y, c}, {a, b}}
  end

  @impl CubeWrapper
  @spec side({integer, integer}) :: integer
  def side({x, y}) do
    side_width = 4

    side_map = %{
      {{2 * side_width, 3 * side_width - 1}, {0 * side_width, 1 * side_width - 1}} => 1,
      {{0 * side_width, 1 * side_width - 1}, {1 * side_width, 2 * side_width - 1}} => 2,
      {{1 * side_width, 2 * side_width - 1}, {1 * side_width, 2 * side_width - 1}} => 3,
      {{2 * side_width, 3 * side_width - 1}, {1 * side_width, 2 * side_width - 1}} => 4,
      {{2 * side_width, 3 * side_width - 1}, {2 * side_width, 3 * side_width - 1}} => 5,
      {{3 * side_width, 4 * side_width - 1}, {2 * side_width, 3 * side_width - 1}} => 6,
    }

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
