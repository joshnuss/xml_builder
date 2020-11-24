defmodule XmlBuilder.Format.None do
  @moduledoc "Documentation for #{__MODULE__}"

  def indentation(_level, _options), do: ""

  def line_break, do: ""
end
