defmodule XmlBuilder do
  def doc(name) when is_bitstring(name) or is_atom(name),
    do: doc({name})

  def doc(list) when is_list(list),
    do: build_content(list)

  def doc({name}),
    do: doc({name, nil, nil})

  def doc({name, attrs}) when is_map(attrs),
    do: doc({name, attrs, nil})

  def doc({name, content}),
    do: doc({name, nil, content})

  def doc({name, attrs, content}) when (attrs == nil or map_size(attrs) == 0) and (content==nil or (is_list(content) and length(content)==0)),
    do: "<#{name}/>"

  def doc({name, attrs, content}) when content==nil or (is_list(content) and length(content)==0),
    do: "<#{name} #{build_attributes(attrs)}/>"

  def doc({name, attrs, content}) when attrs == nil or map_size(attrs) == 0,
    do: "<#{name}>#{build_content(content)}</#{name}>"

  def doc({name, attrs, content}),
    do: "<#{name} #{build_attributes(attrs)}>#{build_content(content)}</#{name}>"

  def doc(name, attrs) when is_map(attrs),
    do: doc({name, attrs, nil})

  def doc(name, content),
    do: doc({name, nil, content})

  def doc(name, attrs, content),
    do: doc({name, attrs, content})

  defp build_content(children) when is_list(children),
    do: Enum.map_join(children, "", &doc/1)

  defp build_content(content),
    do: content

  defp build_attributes(attrs),
    do: Enum.map_join(attrs, " ", fn {k,v} -> ~s/#{k}="#{v}"/ end)
end
