defmodule AdventOfCode.Day22.CubeWrapper do
  @callback wrap({Integer.t, Integer.t, Integer.t}, {Integer.t, Integer.t}) :: {{Integer.t, Integer.t, Integer.t}, {Integer.t, Integer.t}}
  @callback side({Integer.t, Integer.t}) :: Integer.t
end
