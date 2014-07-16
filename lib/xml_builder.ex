defmodule XmlBuilder do
  def doc(name_or_tuple),
    do: doc_type <> element(name_or_tuple)

  def doc(name, attrs_or_content),
    do: doc_type <> element(name, attrs_or_content)

  def doc(name, attrs, content),
    do: doc_type <> element(name, attrs, content)

  def element(name) when is_bitstring(name) or is_atom(name),
    do: element({name})

  def element(list) when is_list(list),
    do: build_content(list)

  def element({name}),
    do: element({name, nil, nil})

  def element({name, attrs}) when is_map(attrs),
    do: element({name, attrs, nil})

  def element({name, content}),
    do: element({name, nil, content})

  def element({name, attrs, content}) when (attrs == nil or map_size(attrs) == 0) and (content==nil or (is_list(content) and length(content)==0)),
    do: "<#{name}/>"

  def element({name, attrs, content}) when content==nil or (is_list(content) and length(content)==0),
    do: "<#{name} #{build_attributes(attrs)}/>"

  def element({name, attrs, content}) when attrs == nil or map_size(attrs) == 0,
    do: "<#{name}>#{build_content(content)}</#{name}>"

  def element({name, attrs, content}),
    do: "<#{name} #{build_attributes(attrs)}>#{build_content(content)}</#{name}>"

  def element(name, attrs) when is_map(attrs),
    do: element({name, attrs, nil})

  def element(name, content),
    do: element({name, nil, content})

  def element(name, attrs, content),
    do: element({name, attrs, content})

  def doc_type,
    do: ~s|<?xml version="1.0">|

  defp build_content(children) when is_list(children),
    do: Enum.map_join(children, "", &element/1)

  defp build_content(content),
    do: content

  defp build_attributes(attrs),
    do: Enum.map_join(attrs, " ", fn {k,v} -> "#{k}=#{quote_attribute_value(v)}" end)

  defp quote_attribute_value(val) when not is_bitstring(val),
    do: quote_attribute_value(to_string(val))

  defp quote_attribute_value(val) do
    double = String.contains?(val, ~s|"|)
    single = String.contains?(val, "'")

    cond do
      double && single ->
        val |> String.replace("\"", "&quot;") |> quote_attribute_value
      double -> "'#{val}'"
      true -> ~s|"#{val}"|
    end
  end
end
