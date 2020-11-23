defmodule XmlBuilder do
  @moduledoc """
  A module for generating XML

  ## Examples

      iex> XmlBuilder.document(:person) |> XmlBuilder.generate
      "<?xml version=\\\"1.0\\\" encoding=\\\"UTF-8\\\"?>\\n<person/>"

      iex> XmlBuilder.document(:person, "Josh") |> XmlBuilder.generate
      "<?xml version=\\\"1.0\\\" encoding=\\\"UTF-8\\\"?>\\n<person>Josh</person>"

      iex> XmlBuilder.document(:person) |> XmlBuilder.generate(format: :none)
      "<?xml version=\\\"1.0\\\" encoding=\\\"UTF-8\\\"?><person/>"

      iex> XmlBuilder.element(:person, "Josh") |> XmlBuilder.generate
      "<person>Josh</person>"

      iex> XmlBuilder.element(:person, %{occupation: "Developer"}, "Josh") |> XmlBuilder.generate
      "<person occupation=\\\"Developer\\\">Josh</person>"
  """

  defmacrop is_blank_attrs(attrs) do
    quote do: is_blank_map(unquote(attrs)) or is_blank_list(unquote(attrs))
  end

  defmacrop is_blank_list(list) do
    quote do: is_nil(unquote(list)) or (is_list(unquote(list)) and length(unquote(list)) == 0)
  end

  defmacrop is_blank_map(map) do
    quote do: is_nil(unquote(map)) or (is_map(unquote(map)) and map_size(unquote(map)) == 0)
  end

  @doc """
  Generate an XML document.

  Returns a `binary`.

  ## Examples

      iex> XmlBuilder.document(:person) |> XmlBuilder.generate
      "<?xml version=\\\"1.0\\\" encoding=\\\"UTF-8\\\"?>\\n<person/>"

      iex> XmlBuilder.document(:person, %{id: 1}) |> XmlBuilder.generate
      "<?xml version=\\\"1.0\\\" encoding=\\\"UTF-8\\\"?>\\n<person id=\\\"1\\\"/>"

      iex> XmlBuilder.document(:person, %{id: 1}, "some data") |> XmlBuilder.generate
      "<?xml version=\\\"1.0\\\" encoding=\\\"UTF-8\\\"?>\\n<person id=\\\"1\\\">some data</person>"
  """
  def document(elements),
    do: [:xml_decl | elements_with_prolog(elements) |> List.wrap()]

  def document(name, attrs_or_content),
    do: [:xml_decl | [element(name, attrs_or_content)]]

  def document(name, attrs, content),
    do: [:xml_decl | [element(name, attrs, content)]]

  @doc false
  def doc(elements) do
    IO.warn("doc/1 is deprecated. Use document/1 with generate/1 instead.")
    [:xml_decl | elements_with_prolog(elements) |> List.wrap()] |> generate
  end

  @doc false
  def doc(name, attrs_or_content) do
    IO.warn("doc/2 is deprecated. Use document/2 with generate/1 instead.")
    [:xml_decl | [element(name, attrs_or_content)]] |> generate
  end

  @doc false
  def doc(name, attrs, content) do
    IO.warn("doc/3 is deprecated. Use document/3 with generate/1 instead.")
    [:xml_decl | [element(name, attrs, content)]] |> generate
  end

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
  def element(name) when is_bitstring(name),
    do: element({nil, nil, name})

  def element(name) when is_bitstring(name) or is_atom(name),
    do: element({name})

  def element(list) when is_list(list),
    do: Enum.map(list, &element/1)

  def element({name}),
    do: element({name, nil, nil})

  def element({name, attrs}) when is_map(attrs),
    do: element({name, attrs, nil})

  def element({name, content}),
    do: element({name, nil, content})

  def element({name, attrs, content}) when is_list(content),
    do: {name, attrs, Enum.map(content, &element/1)}

  def element({name, attrs, content}),
    do: {name, attrs, content}

  def element(name, attrs) when is_map(attrs),
    do: element({name, attrs, nil})

  def element(name, content),
    do: element({name, nil, content})

  def element(name, attrs, content),
    do: element({name, attrs, content})

  @doc """
  Creates a DOCTYPE declaration with a system or public identifier.

  ## System Example

  Returns a `tuple` in the format `{:doctype, [:system, name, system_identifier}`.

  ```elixir
  import XmlBuilder

  document([
    doctype("greeting", system: "hello.dtd"),
    element(:person, "Josh")
  ]) |> generate
  ```

  Outputs

  ```xml
  <?xml version="1.0" encoding="UTF-8" ?>
  <!DOCTYPE greeting SYSTEM "hello.dtd">
  <person>Josh</person>
  ```

  ## Public Example

   Returns a `tuple` in the format `{:doctype, [:public, name, public_identifier, system_identifier}`.

  ```elixir
  import XmlBuilder

  document([
    doctype("html", public: ["-//W3C//DTD XHTML 1.0 Transitional//EN",
                  "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"]),
    element(:html, "Hello, world!")
  ]) |> generate
  ```

  Outputs

  ```xml
  <?xml version="1.0" encoding="UTF-8"?>
  <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
  <html>Hello, world!</html>
  ```
  """
  def doctype(name, [{:system, system_identifier}]),
    do: {:doctype, {:system, name, system_identifier}}

  def doctype(name, [{:public, [public_identifier, system_identifier]}]),
    do: {:doctype, {:public, name, public_identifier, system_identifier}}

  @doc """
  Generate a binary from an XML tree

  Returns a `binary`.

  ## Examples

      iex> XmlBuilder.generate(XmlBuilder.element(:person))
      "<person/>"

      iex> XmlBuilder.generate({:person, %{id: 1}, "Steve Jobs"})
      "<person id=\\\"1\\\">Steve Jobs</person>"

      iex> XmlBuilder.generate({:name, nil, [{:first, nil, "Steve"}]}, format: :none)
      "<name><first>Steve</first></name>"

      iex> XmlBuilder.generate({:name, nil, [{:first, nil, "Steve"}]}, whitespace: "")
      "<name>\\n<first>Steve</first>\\n</name>"

      iex> XmlBuilder.generate({:name, nil, [{:first, nil, "Steve"}]})
      "<name>\\n  <first>Steve</first>\\n</name>"

      iex> XmlBuilder.generate(:xml_decl, encoding: "ISO-8859-1")
      ~s|<?xml version="1.0" encoding="ISO-8859-1"?>|
  """
  def generate(any, options \\ []),
    do: format(any, 0, options) |> IO.chardata_to_string()

  defp format(:xml_decl, 0, options) do
    encoding = Keyword.get(options, :encoding, "UTF-8")

    standalone =
      case Keyword.get(options, :standalone, false) do
        true -> ~s| standalone="yes"|
        false -> ""
      end

    ~s|<?xml version="1.0" encoding="#{encoding}"#{standalone}?>|
  end

  defp format({:doctype, {:system, name, system}}, 0, _options),
    do: ['<!DOCTYPE ', to_string(name), ' SYSTEM "', to_string(system), '">']

  defp format({:doctype, {:public, name, public, system}}, 0, _options),
    do: [
      '<!DOCTYPE ',
      to_string(name),
      ' PUBLIC "',
      to_string(public),
      '" "',
      to_string(system),
      '">'
    ]

  defp format(string, level, options) when is_bitstring(string),
    do: format({nil, nil, string}, level, options)

  defp format(list, level, options) when is_list(list) do
    formatter = formatter(options)
    list |> Enum.map(&format(&1, level, options)) |> Enum.intersperse(formatter.line_break())
  end

  defp format({nil, nil, name}, level, options) when is_bitstring(name),
    do: [indent(level, options), to_string(name)]

  defp format({name, attrs, content}, level, options)
       when is_blank_attrs(attrs) and is_blank_list(content),
       do: [indent(level, options), '<', to_string(name), '/>']

  defp format({name, attrs, content}, level, options) when is_blank_list(content),
    do: [indent(level, options), '<', to_string(name), ' ', format_attributes(attrs), '/>']

  defp format({name, attrs, content}, level, options)
       when is_blank_attrs(attrs) and not is_list(content),
       do: [
         indent(level, options),
         '<',
         to_string(name),
         '>',
         format_content(content, level + 1, options),
         '</',
         to_string(name),
         '>'
       ]

  defp format({name, attrs, content}, level, options)
       when is_blank_attrs(attrs) and is_list(content) do
    format_char = formatter(options).line_break()

    [
      indent(level, options),
      '<',
      to_string(name),
      '>',
      format_content(content, level + 1, options),
      format_char,
      indent(level, options),
      '</',
      to_string(name),
      '>'
    ]
  end

  defp format({name, attrs, content}, level, options)
       when not is_blank_attrs(attrs) and not is_list(content),
       do: [
         indent(level, options),
         '<',
         to_string(name),
         ' ',
         format_attributes(attrs),
         '>',
         format_content(content, level + 1, options),
         '</',
         to_string(name),
         '>'
       ]

  defp format({name, attrs, content}, level, options)
       when not is_blank_attrs(attrs) and is_list(content) do
    format_char = formatter(options).line_break()

    [
      indent(level, options),
      '<',
      to_string(name),
      ' ',
      format_attributes(attrs),
      '>',
      format_content(content, level + 1, options),
      format_char,
      indent(level, options),
      '</',
      to_string(name),
      '>'
    ]
  end

  defp elements_with_prolog([first | rest]) when length(rest) > 0,
    do: [first_element(first) | element(rest)]

  defp elements_with_prolog(element_spec),
    do: element(element_spec)

  defp first_element({:doctype, args} = doctype_decl) when is_tuple(args),
    do: doctype_decl

  defp first_element(element_spec),
    do: element(element_spec)

  defp formatter(options) do
    case Keyword.get(options, :format) do
      :none -> XmlBuilder.Format.None
      _ -> XmlBuilder.Format.Indented
    end
  end

  defp format_content(children, level, options) when is_list(children) do
    format_char = formatter(options).line_break()
    [format_char, Enum.map_join(children, format_char, &format(&1, level, options))]
  end

  defp format_content(content, _level, _options),
    do: escape(content)

  defp format_attributes(attrs),
    do:
      Enum.map_join(attrs, " ", fn {name, value} ->
        [to_string(name), '=', quote_attribute_value(value)]
      end)

  defp indent(level, options) do
    formatter = formatter(options)
    formatter.indentation(level, options)
  end

  defp quote_attribute_value(val) when not is_bitstring(val),
    do: quote_attribute_value(to_string(val))

  defp quote_attribute_value(val) do
    double = String.contains?(val, ~s|"|)
    single = String.contains?(val, "'")
    escaped = escape(val)

    cond do
      double && single ->
        escaped |> String.replace("\"", "&quot;") |> quote_attribute_value

      double ->
        "'#{escaped}'"

      true ->
        ~s|"#{escaped}"|
    end
  end

  defp escape({:cdata, data}), do: ["<![CDATA[", data, "]]>"]

  defp escape(data) when is_binary(data),
    do: data |> escape_string() |> to_string()

  defp escape(data) when not is_bitstring(data),
    do: data |> to_string() |> escape_string() |> to_string()

  defp escape_string(""), do: ""
  defp escape_string(<<"&"::utf8, rest::binary>>), do: escape_entity(rest)
  defp escape_string(<<"<"::utf8, rest::binary>>), do: ["&lt;" | escape_string(rest)]
  defp escape_string(<<">"::utf8, rest::binary>>), do: ["&gt;" | escape_string(rest)]
  defp escape_string(<<"\""::utf8, rest::binary>>), do: ["&quot;" | escape_string(rest)]
  defp escape_string(<<"'"::utf8, rest::binary>>), do: ["&apos;" | escape_string(rest)]
  defp escape_string(<<c::utf8, rest::binary>>), do: [c | escape_string(rest)]

  defp escape_entity(<<"amp;"::utf8, rest::binary>>), do: ["&amp;" | escape_string(rest)]
  defp escape_entity(<<"lt;"::utf8, rest::binary>>), do: ["&lt;" | escape_string(rest)]
  defp escape_entity(<<"gt;"::utf8, rest::binary>>), do: ["&gt;" | escape_string(rest)]
  defp escape_entity(<<"quot;"::utf8, rest::binary>>), do: ["&quot;" | escape_string(rest)]
  defp escape_entity(<<"apos;"::utf8, rest::binary>>), do: ["&apos;" | escape_string(rest)]
  defp escape_entity(rest), do: ["&amp;" | escape_string(rest)]

end
