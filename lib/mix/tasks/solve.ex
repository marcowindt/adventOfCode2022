defmodule Mix.Tasks.Solve do
  use Mix.Task

  def run(["--all"]) do
    {time, :ok} = :timer.tc(fn ->
      1..25
      |> Enum.each(fn day ->
        IO.puts("====== Day #{String.pad_leading("#{day}", 2, "0")} ======")
        run(["#{day}"])
      end)
    end)

    IO.puts("took #{time / 1000} ms")
  end

  def run([day]) do
    module = String.to_existing_atom("Elixir.AdventOfCode.Day#{String.pad_leading(day, 2, "0")}.Solution")
    module.run()
  end
end
