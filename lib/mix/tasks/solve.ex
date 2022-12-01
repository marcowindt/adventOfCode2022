defmodule Mix.Tasks.Solve do
  use Mix.Task

  def run([day]) do
    module = String.to_existing_atom("Elixir.AdventOfCode.Day#{String.pad_leading(day, 2, "0")}.Solution")
    module.run()
  end
end
