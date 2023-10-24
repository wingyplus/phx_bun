defmodule PhxBunTest do
  use ExUnit.Case
  doctest Bun

  test "install" do
    # Ensure build path is clean.
    File.rm_rf!(Bun.bin_path())
    assert :ok = Mix.Task.rerun("bun.install")
    assert File.exists?(Bun.bin_path())
    File.rm_rf!(Bun.bin_path())
  end
end
