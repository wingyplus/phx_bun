defmodule Mix.Tasks.Bun.Install do
  @moduledoc "Installing Bun"

  use Mix.Task

  @impl Mix.Task
  def run(_args) do
    Application.ensure_all_started(:ssl)
    Application.ensure_started(:inets)

    case Bun.install() do
      :ok ->
        Mix.shell().info("""
        Bun installed successfully!
        """)

      otherwise ->
        Mix.shell().error("""
        Cannot install Bun, cause: 

            #{inspect(otherwise)}
        """)
    end
  end
end
