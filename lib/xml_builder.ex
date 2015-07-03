defmodule XmlBuilder do
  @moduledoc """
  A module for generating XML

  ## Examples

      iex> XmlBuilder.doc(:person)
      "<?xml version=\\\"1.0\\\" encoding=\\\"UTF-8\\\" ?>\\n<person/>"

      iex> XmlBuilder.doc(:person, "Josh")
      "<?xml version=\\\"1.0\\\" encoding=\\\"UTF-8\\\" ?>\\n<person>Josh</person>"

      iex> XmlBuilder.comment("a person") |> XmlBuilder.generate
      "<!--a person-->"

      iex> XmlBuilder.element(:person, "Josh") |> XmlBuilder.generate
      "<person>Josh</person>"

      iex> XmlBuilder.element(:person, %{occupation: "Developer"}, "Josh") |> XmlBuilder.generate
      "<person occupation=\\\"Developer\\\">Josh</person>"
  """

  def doc(name_or_tuple),
    do: [:_doc_type | tree_node(name_or_tuple) |> List.wrap] |> generate

  def doc(name, attrs_or_content),
    do: [:_doc_type | [element(name, attrs_or_content)]] |> generate

  def doc(name, attrs, content),
    do: [:_doc_type | [element(name, attrs, content)]] |> generate

  def comment(content),
    do: {:comment, content}

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
    do: {:element, name, attrs, Enum.map(content, &tree_node/1)}

  def element({name, attrs, content}),
    do: {:element, name, attrs, content}

  def element(name, attrs) when is_map(attrs),
    do: element({name, attrs, nil})

  def element(name, content),
    do: element({name, nil, content})

  def element(name, attrs, content),
    do: element({name, attrs, content})

  def generate(any),
    do: generate(any, 0)

  def generate(:_doc_type, 0),
    do: ~s|<?xml version="1.0" encoding="UTF-8" ?>|

  def generate(list, level) when is_list(list),
    do: list |> Enum.map(&(generate(&1, level))) |> Enum.intersperse("\n") |> Enum.join

  def generate({:comment, content}, level),
    do: "#{indent(level)}<!--#{generate_content(content, level+1)}-->"

  def generate({:element, name, attrs, content}, level) when (attrs == nil or map_size(attrs) == 0) and (content==nil or (is_list(content) and length(content)==0)),
    do: "#{indent(level)}<#{name}/>"

  def generate({:element, name, attrs, content}, level) when content==nil or (is_list(content) and length(content)==0),
    do: "#{indent(level)}<#{name} #{generate_attributes(attrs)}/>"

  def generate({:element, name, attrs, content}, level) when (attrs == nil or map_size(attrs) == 0) and not is_list(content),
    do: "#{indent(level)}<#{name}>#{generate_content(content, level+1)}</#{name}>"

  def generate({:element, name, attrs, content}, level) when (attrs == nil or map_size(attrs) == 0) and is_list(content),
    do: "#{indent(level)}<#{name}>#{generate_content(content, level+1)}\n#{indent(level)}</#{name}>"

  def generate({:element, name, attrs, content}, level) when map_size(attrs) > 0 and not is_list(content),
    do: "#{indent(level)}<#{name} #{generate_attributes(attrs)}>#{generate_content(content, level+1)}</#{name}>"

  def generate({:element, name, attrs, content}, level) when map_size(attrs) > 0 and is_list(content),
    do: "#{indent(level)}<#{name} #{generate_attributes(attrs)}>#{generate_content(content, level+1)}\n#{indent(level)}</#{name}>"

  defp tree_node(tuple={:comment, _content}),
    do: tuple

  defp tree_node(element_spec),
    do: element(element_spec)

  defp generate_content(children, level) when is_list(children),
    do: "\n" <> Enum.map_join(children, "\n", &(generate(&1, level)))

  defp generate_content(content, _level),
    do: escape(content)

  defp generate_attributes(attrs),
    do: Enum.map_join(attrs, " ", fn {k,v} -> "#{k}=#{quote_attribute_value(v)}" end)

  defp indent(level),
    do: String.duplicate("\t", level)

  defp quote_attribute_value(val) when not is_bitstring(val),
    do: quote_attribute_value(to_string(val))

  defp quote_attribute_value(val) do
    double = String.contains?(val, ~s|"|)
    single = String.contains?(val, "'")
    escaped = escape(val)

    cond do
      double && single ->
        escaped |> String.replace("\"", "&quot;") |> quote_attribute_value
      double -> "'#{escaped}'"
      true -> ~s|"#{escaped}"|
    end
  end

  defp escape(data) when not is_bitstring(data),
    do: escape(to_string(data))

  defp escape(string) do
    string 
    |> String.replace(">", "&gt;") 
    |> String.replace("<", "&lt;")
    |> replace_ampersand
  end

  defp replace_ampersand(string) do
    Regex.replace(~r/&(?!lt;|gt;|quot;)/, string, "&amp;")
  end
end
