defmodule XmlBuilder do
  @moduledoc """
  A module for generating XML

  ## Examples

      iex> XmlBuilder.doc(:person)
      "<?xml version=\\\"1.0\\\" encoding=\\\"UTF-8\\\"?>\\n<person/>"

      iex> XmlBuilder.doc(:person, "Josh")
      "<?xml version=\\\"1.0\\\" encoding=\\\"UTF-8\\\"?>\\n<person>Josh</person>"

      iex> XmlBuilder.element(:person, "Josh") |> XmlBuilder.generate
      "<person>Josh</person>"

      iex> XmlBuilder.element(:person, %{occupation: "Developer"}, "Josh") |> XmlBuilder.generate
      "<person occupation=\\\"Developer\\\">Josh</person>"
  """

  @doc """
  Generate an XML document.

  Returns a `binary`.

  ## Examples

      iex> XmlBuilder.doc(:person)
      "<?xml version=\\\"1.0\\\" encoding=\\\"UTF-8\\\"?>\\n<person/>"

      iex> XmlBuilder.doc(:person, %{id: 1})
      "<?xml version=\\\"1.0\\\" encoding=\\\"UTF-8\\\"?>\\n<person id=\\\"1\\\"/>"

      iex> XmlBuilder.doc(:person, %{id: 1}, "some data")
      "<?xml version=\\\"1.0\\\" encoding=\\\"UTF-8\\\"?>\\n<person id=\\\"1\\\">some data</person>"
  """

  def doc(name_or_tuple),
    do: [:_doc_type | element(name_or_tuple) |> List.wrap] |> generate

  def doc(name, attrs_or_content),
    do: [:_doc_type | [element(name, attrs_or_content)]] |> generate

  def doc(name, attrs, content),
    do: [:_doc_type | [element(name, attrs, content)]] |> generate

  @doc """
  Create an XML element.

  Returns a `tuple` in the format `{name, attributes, content | list}`.

  ## Examples

      iex> XmlBuilder.element(:person)
      {:person, nil, nil}

      iex> XmlBuilder.element(:person, "data")
      {:person, nil, "data"}

      iex> XmlBuilder.element(:person, %{id: 1})
      {:person, %{id: 1}, nil}

      iex> XmlBuilder.element(:person, %{id: 1}, "data")
      {:person, %{id: 1}, "data"}

      iex> XmlBuilder.element(:person, %{id: 1}, [XmlBuilder.element(:first, "Steve"), XmlBuilder.element(:last, "Jobs")])
      {:person, %{id: 1}, [
        {:first, nil, "Steve"},
        {:last, nil, "Jobs"}
      ]}
  """
  @spec element(name :: String.t | nil,
                attrs :: Map.t | nil,
                content :: Tuple.t | String.t | List.t | nil) :: XmlBuilder.Element.t
  defdelegate element(a1), to: XmlBuilder.Element, as: :as_tuple
  defdelegate element(a1, a2), to: XmlBuilder.Element, as: :as_tuple
  defdelegate element(a1, a2, a3), to: XmlBuilder.Element, as: :as_tuple

  @doc """
  Generate a binary from an XML tree

  Returns a `binary`.

  ## Examples

      iex> XmlBuilder.generate(XmlBuilder.element(:person))
      "<person/>"

      iex> XmlBuilder.generate({:person, %{id: 1}, "Steve Jobs"})
      "<person id=\\\"1\\\">Steve Jobs</person>"
  """
  def generate(any, opts \\ [formatter: XmlBuilder.Formatters.Default]),
    do: apply(opts[:formatter] || default(), :format, [any, 0]) |> IO.chardata_to_string

  defp default,
    do: Application.get_env(:xml_builder, :formatter, XmlBuilder.Formatters.Default)

end
