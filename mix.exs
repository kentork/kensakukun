defmodule Kensakukun.MixProject do
  use Mix.Project

  def project do
    [
      app: :kensakukun,
      version: "0.1.0",
      elixir: ">= 1.5.3",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Kensakukun, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:cowboy, "~> 1.1"},
      {:plug, "~> 1.5.0-rc.0"},
      {:poison, "~> 3.1.0"},
      {:httpotion, "~> 3.0.3"}
    ]
  end
end
