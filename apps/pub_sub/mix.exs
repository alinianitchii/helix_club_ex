defmodule Pubsub.MixProject do
  use Mix.Project

  def project do
    [
      app: :pub_sub,
      version: "0.1.0",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixir: "~> 1.18",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      elixirc_paths: elixirc_paths(Mix.env())
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {PubSub.Application, []}
    ]
  end

  defp elixirc_paths(:test), do: ["lib"]
  defp elixirc_paths(_env), do: ["lib"]

  defp deps do
    [
      {:phoenix_pubsub, "~> 2.0"}
    ]
  end
end
