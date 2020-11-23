defmodule XmlBuilder.Mixfile do
  use Mix.Project

  def project do
    [
      app: :xml_builder,
      version: "2.1.4",
      elixir: ">= 0.14.0",
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

  # Configuration for the OTP application
  #
  # Type `mix help compile.app` for more information
  def application do
    [applications: []]
  end

  # Dependencies can be hex.pm packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1"}
  #
  # Type `mix help deps` for more examples and options
  defp deps do
    [{:ex_doc, github: "elixir-lang/ex_doc", only: :dev}]
  end
end
