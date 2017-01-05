XML Builder
=======

[![Build Status](https://travis-ci.org/joshnuss/xml_builder.svg?branch=master)](https://travis-ci.org/joshnuss/xml_builder)

## Overview

An Elixir library for building xml.

Each xml node is structured as a tuple of name, attributes map and content/list:

```elixir
{name, attrs, content | list}
```

## Installation

Add dependency to your project's `mix.exs`

```elixir
def deps do
  [{:xml_builder, "~> 0.0.6"}]
end
```

## Examples

### A simple element

Like `<person id="12345">Josh</person>`, would look like:

```elixir
{:person, %{id: 12345}, "Josh"} |> XmlBuilder.generate
```

### An element with child elements

Like `<person id="12345"><first>Josh</first><last>Nussbaum</last></person>`

```elixir
{:person, %{id: 12345}, [{:first, nil, "Josh"}, {:last, nil, "Nussbaum"}]} |> XmlBuilder.generate
```

### Convenience Functions

For more readability, you can use XmlBuilder's methods instead of creating tuples manually.

```elixir
XmlBuilder.doc(:person, "Josh")
```

Outputs

```xml
<?xml version="1.0" encoding="UTF-8" ?>
<person>Josh</person>
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

iex> [person(123, "Steve", "Jobs"),
      person(456, "Steve", "Wozniak")] |> generate
```

Outputs

```xml
<person id="123">
  <first>Steve</first>
  <last>Jobs</last>
</person>"
<person id="456">
  <first>Steve</first>
  <last>Wozniak</last>
</person>"
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
