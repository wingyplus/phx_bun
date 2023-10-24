Mix.install([:dagger])

client = Dagger.connect!()

project =
  client
  |> Dagger.Client.host()
  |> Dagger.Host.directory(".", excludes: ["_build"])

for platform <- ["linux/amd64", "linux/arm64"] do
  client
  |> Dagger.Client.container(platform: platform)
  |> Dagger.Container.from("hexpm/elixir:1.15.7-erlang-26.1.2-ubuntu-jammy-20230126")
  |> Dagger.Container.with_env_variable("LANG", "C.UTF-8")
  |> Dagger.Container.with_env_variable("ERL_FLAGS", "+JMsingle true")
  |> Dagger.Container.with_exec(~w"mix local.hex --force")
  |> Dagger.Container.with_exec(~w"mix local.rebar --force")
  |> Dagger.Container.with_mounted_directory("/app", project)
  |> Dagger.Container.with_workdir("/app")
  |> Dagger.Container.with_exec(~w"mix deps.get")
  |> Dagger.Container.with_exec(~w"mix test")
  |> Dagger.Sync.sync()
end

Dagger.close(client)
