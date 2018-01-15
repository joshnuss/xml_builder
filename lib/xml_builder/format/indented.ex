defmodule XmlBuilder.Format.Indented do
  def indentation(level, options) do
    whitespace = Keyword.get(options, :whitespace, "  ")

    String.duplicate(whitespace, level)
  end

  def line_break(), do: "\n"
end
