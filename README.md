XML Builder
=======

## Overview

An Elixir library for building xml.

Each xml node is structured as a tuple of name, attributes map and content/list:

```elixir
{name, attrs, content | list}
```

## Installation

```elixir
def deps do
  [{:xml_builder, "~> 0.0.4"}]
end
```

## Examples

### A simple element

Like `<person id="12345">Josh</person>`, would look like:

```elixir
{:person, %{id: 12345}, "Josh"}
```

### An element with child elements

Like `<person id="12345"><first>Josh</first><last>Nussbaum</last></person>`

```elixir
{:person, %{id: 12345}, [{:first, nil, "Josh"}, {:last, nil, "Nussbaum"}]}
```

### Convenience Functions

For more readability, you can use XmlBuilder's methods instead of creating tuples manually.

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
"<person id=\"123\"><first>Josh</first><last>Nussbaum</last></person>"
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
"<person id=\"123\"><first>Josh</first><last>Nussbaum</last></person>"
```
