defmodule XmlBuilder do
  def xml(name) when is_bitstring(name) or is_atom(name),
    do: xml({name})

  def xml(list) when is_list(list),
    do: build_content(list)

  def xml({name}),
    do: xml({name, nil, nil})

  def xml({name, attrs}) when is_map(attrs),
    do: xml({name, attrs, nil})

  def xml({name, content}),
    do: xml({name, nil, content})

  def xml({name, attrs, content}) when (attrs == nil or map_size(attrs) == 0) and (content==nil or (is_list(content) and length(content)==0)),
    do: "<#{name}/>"

  def xml({name, attrs, content}) when content==nil or (is_list(content) and length(content)==0),
    do: "<#{name} #{build_attributes(attrs)}/>"

  def xml({name, attrs, content}) when attrs == nil or map_size(attrs) == 0,
    do: "<#{name}>#{build_content(content)}</#{name}>"

  def xml({name, attrs, content}),
    do: "<#{name} #{build_attributes(attrs)}>#{build_content(content)}</#{name}>"

  def xml(name, attrs) when is_map(attrs),
    do: xml({name, attrs, nil})

  def xml(name, content),
    do: xml({name, nil, content})

  def xml(name, attrs, content),
    do: xml({name, attrs, content})

  defp build_content(children) when is_list(children),
    do: Enum.map_join(children, "", &xml/1)

  defp build_content(content),
    do: content

  defp build_attributes(attrs),
    do: Enum.map_join(attrs, " ", fn {k,v} -> ~s/#{k}="#{v}"/ end)
end
