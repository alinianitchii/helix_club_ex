defmodule HelixClub.MixProject do
  use Mix.Project

  def project do
    [
      apps_path: "apps",
      version: "0.1.0",
      elixir: "~> 1.18.4",
      start_permanent: Mix.env() == :dev,
      deps: deps(),
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/alinianitchii/helix_club_ex"},
      releases: [
        helix_club: [
          applications: [
            memberships: :permanent,
            payments: :permanent,
            people: :permanent
          ]
        ]
      ]
    ]
  end

  # Dependencies listed here are available only for this
  # project and cannot be accessed from applications inside
  # the apps folder.
  #
  # Run "mix help deps" for examples and options.
  defp deps do
    [
      {:jason, "~> 1.3"},
      {:uuid, "~> 1.1"},
      {:ecto_sql, "~> 3.0"},
      {:postgrex, ">= 0.0.0"},
      {:oban, "~> 2.19"}
    ]
  end
end
