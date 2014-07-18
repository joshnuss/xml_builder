XML Builder
=======

Elixir library for building xml.

## Overview

Each xml node is structured as a tuple of name, attributes map and content/list:

```elixir
{name, attrs, content | list}
```

### A simple element

Like `<person>Josh</person>`, would look like:

```elixir
{:person, %{id: 12345}, "Josh"}
```

### An element with child elements

Like `<person><first>Josh</first><last>Nussbaum</last></person>`

```elixir
{:person, %{id: 12345}, [{:first, nil, "Josh"}, {:last, nil, "Nussbaum"}]}
```

### Convenience Functions

For more readability, you dont need to create tuples manually, use XmlBuilder's methods instead.

```elixir
XmlBuilder.doc(:person, "Josh")
```

#### Building up an element

An element can be built using multiple calls to the `element` function

```elixir
import XmlBuilder

def person(id, first, last) do
  element(:person, %{id: id}, [
    element(:first, first),
    element(:last, last)
  ])
end

iex> person(123, "Josh", "Nussbaum") |> generate
"<person><first>Josh</first><last>Nussbaum</last></person>"
```

#### Using keyed lists

The previous example can be simplified using a keyed list

```elixir
import XmlBuilder

def person(id, first, last) do
  element(:person, %{id: id}, first: first,
                              last: last)
end

iex> person(123, "Josh", "Nussbaum") |> generate
"<person><first>Josh</first><last>Nussbaum</last></person>"
```
