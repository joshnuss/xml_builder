defmodule Builder do
  def xml(name),
    do: "<#{name}/>"

  def xml(name, content),
    do: "<#{name}>#{content}</#{name}>"
end
