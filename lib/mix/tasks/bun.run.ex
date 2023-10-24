defmodule Mix.Tasks.Bun.Run do
  @moduledoc "Running Bun command from profile defined in config"

  use Mix.Task

  @impl Mix.Task
  def run([]) do
    run(["default"])
  end

  # TODO: support extra args
  @impl Mix.Task
  def run([profile]) do
    Bun.run(String.to_atom(profile))
  end
end
