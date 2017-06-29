defmodule XmlBuilder.Formatters.None do
  @moduledoc ~S"""
  Formatter for `XmlBuilder.generate/2` to produce a machine-readable aka
    minified XML.

  Unlike `XmlBuilder.Formatters.Indented`, this formatter does not
    produce a human readable XML, it simply spits out elements one immediately
  after another, like this:

  ```xml
  <person><name id=\"123\">Josh</name><age>21</age></person>
  ```

  **Normally you should not use this formatter explicitly, pass it as an
  optional parameter to `XmlBuilder.generate/2` instead.**

  ## Examples

      iex> "Expect unindented"
      ...> |> XmlBuilder.Formatters.None.format(3)
      ["", "Expect unindented"]

      iex> [indent | _] = {:a, %{href: "link"}, "text"}
      ...>                |> XmlBuilder.Formatters.None.format(2)
      ...> indent
      ""
  """
  use XmlBuilder.Formatter, indent: "", intersperse: "", blank: ""
end
