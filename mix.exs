defmodule Blacksmith.Mixfile do
  use Mix.Project

  def project do
    [app: :blacksmith,
     version: "0.2.0",
     elixir: "~> 1.0",
     deps: deps,
     name: "Blacksmith",
     source_url: "https://github.com/batate/blacksmith",
     docs: fn ->
       {ref, 0} = System.cmd("git", ["rev-parse", "--verify", "--quiet", "HEAD"])
       [source_ref: ref, main: "README", readme: "README.md"]
     end,
     description: "Elixir fake data generation for testing and development",
     package: package]
  end

  def application do
    [applications: [:logger, :faker],
      mod: {Blacksmith.App, []},
      env: [locale: :en]]
  end

  defp package do
    [contributors: ["Bruce Tate", "Eric Meadows-Jönsson"],
     licenses: ["Apache 2.0"],
     links: %{"Github" => "https://github.com/batate/blacksmith"}]
  end

  defp deps do
    [{:faker, "~> 0.6"},
     {:ex_doc, only: :dev},
     {:earmark, only: :dev},
     {:shouldi, only: :test}]
  end
end
