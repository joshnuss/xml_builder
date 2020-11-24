defmodule XmlBuilder.Mixfile do
  use Mix.Project

  @source_url "https://github.com/joshnuss/xml_builder"

  def project do
    [
      app: :xml_builder,
      version: "2.1.4",
      elixir: "~> 1.6",
      deps: deps(),
      docs: docs(),
      package: [
        maintainers: ["Joshua Nussbaum"],
        licenses: ["MIT"],
        links: %{GitHub: @source_url}
      ],
      description: "XML builder for Elixir"
    ]
  end

  def application do
    [applications: []]
  end

  defp deps do
    [
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false}
    ]
  end

  defp docs do
    [
      main: "readme",
      source_url: @source_url,
      extras: ["README.md"]
    ]
  end
end
