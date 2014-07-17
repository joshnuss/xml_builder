defmodule XmlBuilder do
  @moduledoc """
  A module for generating XML

  ## Examples

      iex> XmlBuilder.doc(:person) |> XmlBuilder.generate
      "<?xml version=\\\"1.0\\\"><person/>"

      iex> XmlBuilder.doc(:person, "Josh") |> XmlBuilder.generate
      "<?xml version=\\\"1.0\\\"><person>Josh</person>"

      iex> XmlBuilder.element(:person, "Josh") |> XmlBuilder.generate
      "<person>Josh</person>"

      iex> XmlBuilder.element(:person, %{occupation: "Developer"}, "Josh") |> XmlBuilder.generate
      "<person occupation=\\\"Developer\\\">Josh</person>"
  """

  def doc(name_or_tuple),
    do: [:_doc_type | element(name_or_tuple) |> List.wrap]

  def doc(name, attrs_or_content),
    do: [:_doc_type | [element(name, attrs_or_content)]]

  def doc(name, attrs, content),
    do: [:_doc_type | [element(name, attrs, content)]]

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

  def element(name, attrs) when is_map(attrs),
    do: element({name, attrs, nil})

  def element(name, content),
    do: element({name, nil, content})

  def element({name, attrs, content}) when is_list(content),
    do: {name, attrs, Enum.map(content, &element/1)}

  def element(name, attrs, content),
    do: element({name, attrs, content})

  def element(tuple={_name, _attrs, _content}),
    do: tuple

  def generate(:_doc_type),
    do: ~s|<?xml version="1.0">|

  def generate(list) when is_list(list),
    do: Enum.map_join(list, &generate/1)

  def generate({name, attrs, content}) when (attrs == nil or map_size(attrs) == 0) and (content==nil or (is_list(content) and length(content)==0)),
    do: "<#{name}/>"

  def generate({name, attrs, content}) when content==nil or (is_list(content) and length(content)==0),
    do: "<#{name} #{generate_attributes(attrs)}/>"

  def generate({name, attrs, content}) when attrs == nil or map_size(attrs) == 0,
    do: "<#{name}>#{generate_content(content)}</#{name}>"

  def generate({name, attrs, content}),
    do: "<#{name} #{generate_attributes(attrs)}>#{generate_content(content)}</#{name}>"

  defp generate_content(children) when is_list(children),
    do: Enum.map_join(children, "", &generate/1)

  defp generate_content(content),
    do: escape(content)

  defp generate_attributes(attrs),
    do: Enum.map_join(attrs, " ", fn {k,v} -> "#{k}=#{quote_attribute_value(v)}" end)

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

  defp escape(string),
    do: string |> String.replace(">", "&gt;") |> String.replace("<", "&lt;")
end
