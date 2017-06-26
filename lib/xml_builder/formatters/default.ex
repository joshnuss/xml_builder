defmodule XmlBuilder.Formatters.Default do
  use XmlBuilder.Formatter, indent: "\t", intersperse: "\n", blank: ""
end
