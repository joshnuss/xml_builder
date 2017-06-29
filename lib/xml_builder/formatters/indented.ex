defmodule XmlBuilder.Formatters.Indented do
  @moduledoc ~S"""
  Formatter for `XmlBuilder.generate/2` to produce a human-readable indented XML.

  Unlike `XmlBuilder.Formatters.None`, this formatter
    produces a human readable XML, indented with tabs and new lines, like this:

  ```xml
  <person>
    <name id=\"123\">Josh</name>
    <age>21</age>
  </person>
  ```

  **Normally you should not use this formatter explicitly, pass it as an
  optional parameter to `XmlBuilder.generate/2` instead.**

  ## Examples

      iex> "Expect unindented"
      ...> |> XmlBuilder.Formatters.Indented.format(3)
      ["\t\t\t", "Expect unindented"]

      iex> [indent | _] = {:a, %{href: "link"}, "text"}
      ...>                |> XmlBuilder.Formatters.Indented.format(2)
      ...> indent
      "\t\t"
  """
  use XmlBuilder.Formatter, indent: "\t", intersperse: "\n", blank: ""
end
