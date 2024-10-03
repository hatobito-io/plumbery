defmodule Plumbery.MixProject do
  use Mix.Project

  def project do
    [
      app: :plumbery,
      version: "0.1.0",
      elixir: "~> 1.14",
      xonsolidate_protocols: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      elixirc_paths: elixirc_paths(Mix.env()),
      deps: deps(),
      aliases: aliases(),
      source_url: "https://github.com/hatobito-io/plumbery",
      homepage_url: "https://github.com/hatobito-io/plumbery",
      docs: [
        markdown_processor: Plumbery.Docs.Preprocessor,
        api_reference: false,
        main: "readme",
        extras: [
          "README.md",
          "documentation/dsls/DSL:-Plumbery.md",
          "documentation/guides/installation.md"
        ],
        groups_for_extras: [
          Guides: Path.wildcard("documentation/guides/*.md"),
          DSL: Path.wildcard("documentation/dsls/*.md")
        ]
      ]
    ]
  end

  def application do
    [
      extra_applications: []
    ]
  end

  defp deps do
    [
      {:spark, "~> 2.2.29"},
      {:ex_doc, "~> 0.34", only: [:dev, :test], runtime: false}
    ]
  end

  defp aliases do
    [
      docs: [
        "spark.cheat_sheets",
        "docs"
      ],
      "spark.cheat_sheets": "spark.cheat_sheets --extensions Plumbery.Dsl"
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "examples", "test/support"]
  defp elixirc_paths(_), do: ["lib"]
end
