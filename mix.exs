defmodule XmlBuilder.Mixfile do
  use Mix.Project

  def project do
    [
      app: :xml_builder,
      version: "2.1.4",
      elixir: "~> 1.6",
      deps: deps(),
      package: [
        maintainers: ["Joshua Nussbaum"],
        licenses: ["MIT"],
        links: %{github: "https://github.com/joshnuss/xml_builder"}
      ],
      description: """
      XML builder for Elixir
      """
    ]
  end

  def application do
    [applications: []]
  end

  defp deps do
    [{:ex_doc, github: "elixir-lang/ex_doc", only: :dev}]
  end
end
