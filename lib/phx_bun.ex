defmodule Bun do
  @moduledoc """
  An installer for [Bun](https://bun.sh/).
  """

  @doc """
  Installs Bun.
  """
  def install() do
    Application.ensure_started(:ssl)
    Application.ensure_started(:inets)

    version = config_version()

    with {:ok, zip} <- download(version, target()),
         {:ok, bun_path} <- extract(zip, build_path()) do
      File.chmod(bun_path, 0o755)
    end
  end

  @doc """
  Running a Bun command from given `profile`.
  """
  def run(profile, extra_args \\ []) do
    config = config_for!(profile)

    bin_path()
    |> System.cmd(config[:args] ++ extra_args)
    |> elem(0)
  end

  @doc """
  Get configured version.
  """
  def config_version() do
    Application.get_env(:phx_bun, :version, latest_version())
  end

  @doc """
  Returns the latest version tracked by this library.
  """
  def latest_version() do
    "1.0.7"
  end

  @doc """
  Download `bun` from the internet.
  """
  def download(version, {os, arch}) do
    url = "https://github.com/oven-sh/bun/releases/download/bun-v#{version}/bun-#{os}-#{arch}.zip"

    with {:ok, {_, _, zip}} <-
           :httpc.request(:get, {url, []}, [], body_format: :binary) do
      {:ok, zip}
    end
  end

  defp config_for!(profile) do
    Application.get_env(:phx_bun, profile) ||
      raise """
      No configuration for profile #{profile}. To configure profile, simply put this configuration to your config.exs:

          config :phx_bun,
            #{profile}: [
              args: ...
            ]
      """
  end

  defp extract(zip, destination) do
    with {:ok, [path]} <- :zip.extract(zip, cwd: String.to_charlist(destination)) do
      {:ok, to_string(path)}
    end
  end

  defp build_path() do
    Path.expand(Path.join(["_build"]))
  end

  defp bin_path() do
    {os, arch} = target()
    Path.join([build_path(), "bun-#{os}-#{arch}", "bun"])
  end

  defp target() do
    # TODO: support more arch.
    case :os.type() do
      {:unix, :darwin} -> {:darwin, arch()}
    end
  end

  defp arch() do
    case :erlang.system_info(:system_architecture) |> to_string() do
      "aarch64" <> _rest -> :aarch64
    end
  end
end
