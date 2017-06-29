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
  defdelegate element(a1), to: XmlBuilder.Element, as: :to_element
  defdelegate element(a1, a2), to: XmlBuilder.Element, as: :to_element
  defdelegate element(a1, a2, a3), to: XmlBuilder.Element, as: :to_element

  @doc """
  Generate a binary from an XML tree. Accepts an optional parameter
    `formatter: Formatter.Module.Name` to specify the formatter to use.
  The `formatter` parameter might be shortened to `:none` and `:indented`
    for built-in formatters.

  Returns a `binary`.

  ## Examples

      iex> XmlBuilder.generate(XmlBuilder.element(:person))
      "<person/>"

      iex> XmlBuilder.generate({:person, %{id: 1}, "Steve Jobs"})
      "<person id=\\\"1\\\">Steve Jobs</person>"

      iex> XmlBuilder.generate(
      ...>  [{:person, %{},
      ...>    [{:name, %{id: 123}, "Josh"},
      ...>     {:age, %{}, "21"}]}], formatter: XmlBuilder.Formatters.None)
      "<person><name id=\\\"123\\\">Josh</name><age>21</age></person>"

      iex> XmlBuilder.generate(
      ...>  [{:person, %{},
      ...>    [{:name, %{id: 123}, "Josh"},
      ...>     {:age, %{}, "21"}]}], formatter: :none)
      "<person><name id=\\\"123\\\">Josh</name><age>21</age></person>"
  """
  def generate(any, opts \\ [formatter: XmlBuilder.Formatters.Indented]),
    do: apply(safe_formatter(opts[:formatter]), :format, [any, 0]) |> IO.chardata_to_string

  defp safe_formatter(name) when is_binary(name),
    do: safe_formatter(String.to_atom(name))

  defp safe_formatter([name]) when is_binary(name),
    do: safe_formatter(Module.concat(["XmlBuilder", "Formatters", String.capitalize(name)]))

  defp safe_formatter(name) when is_list(name),
    do: safe_formatter(Application.get_env(:xml_builder, :formatter, XmlBuilder.Formatters.Indented))

  defp safe_formatter(name) when is_atom(name) do
    case Code.ensure_loaded(name) do
      {:module, module} -> module
      {:error, _reason} -> safe_formatter(name |> Atom.to_string() |> String.split("."))
    end
  end
end
