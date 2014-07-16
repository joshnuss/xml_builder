defmodule Builder do
  def xml(name),
    do: "<#{name}/>"

  def xml(name, attrs) when is_map(attrs) and map_size(attrs) == 0,
    do: xml(name)

  def xml(name, attrs) when is_map(attrs),
    do: "<#{name} #{build_attributes(attrs)}/>"

  def xml(name, content),
    do: "<#{name}>#{content}</#{name}>"

  def xml(name, attrs, nil),
    do: xml(name, attrs)

  def xml(name, attrs, content) when is_map(attrs) and map_size(attrs) == 0,
    do: "<#{name}>#{content}</#{name}>"

  def xml(name, attrs, content),
    do: "<#{name} #{build_attributes(attrs)}>#{content}</#{name}>"

  defp build_attributes(attrs),
    do: Enum.map_join(attrs, " ", fn {k,v} -> ~s/#{k}="#{v}"/ end)
end
