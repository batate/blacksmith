defmodule Blacksmith.Mixfile do
  use Mix.Project

  @version "0.2.0"

  def project do
    [app: :blacksmith,
     version: @version,
     elixir: "~> 1.0",
     deps: deps(),
     name: "Blacksmith",
     source_url: "https://github.com/batate/blacksmith",
     docs: docs(),
     description: "Elixir fake data generation for testing and development",
     package: package()]
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

  defp docs do
    [source_ref: "v" <> @version,
     main: "README",
     extras: ["README.md"]]
  end

  defp deps do
    [{:faker, "~> 0.7"},
     {:ex_doc, ">= 0.0.0", only: :dev},
     {:earmark, ">= 0.0.0", only: :dev},
     {:shouldi, ">= 0.3.0", only: :test}]
  end
end
