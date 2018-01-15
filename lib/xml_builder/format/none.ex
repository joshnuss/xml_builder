defmodule XmlBuilder.Format.None do
  def indentation(_level, _options), do: ""
  def line_break(), do: ""
end
