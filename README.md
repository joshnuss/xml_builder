XML Builder
===========

[![CI](https://github.com/joshnuss/xml_builder/workflows/mix/badge.svg)](https://github.com/joshnuss/xml_builder/actions)
[![Module Version](https://img.shields.io/hexpm/v/xml_builder.svg)](https://hex.pm/packages/xml_builder)
[![Hex Docs](https://img.shields.io/badge/hex-docs-lightgreen.svg)](https://hexdocs.pm/xml_builder/)
[![Total Download](https://img.shields.io/hexpm/dt/xml_builder.svg)](https://hex.pm/packages/xml_builder)
[![License](https://img.shields.io/hexpm/l/xml_builder.svg)](https://github.com/joshnuss/xml_builder/blob/master/LICENSE)
[![Last Updated](https://img.shields.io/github/last-commit/joshnuss/xml_builder.svg)](https://github.com/joshnuss/xml_builder/commits/master)


## Overview

An Elixir library for building XML. It is inspired by the late [Jim Weirich](https://github.com/jimweirich)'s awesome [builder](https://github.com/jimweirich/builder) library for Ruby.

Each XML node is structured as a tuple of name, attributes map, and content/list.

```elixir
{name, attrs, content | list}
```

## Installation

Add dependency to your project's `mix.exs`:

```elixir
def deps do
  [{:xml_builder, "~> 2.1"}]
end
```

## Examples

### A simple element

Like `<person id="12345">Josh</person>`, would look like:

```elixir
{:person, %{id: 12345}, "Josh"} |> XmlBuilder.generate
```

### An element with child elements

Like `<person id="12345"><first>Josh</first><last>Nussbaum</last></person>`.

```elixir
{:person, %{id: 12345}, [{:first, nil, "Josh"}, {:last, nil, "Nussbaum"}]} |> XmlBuilder.generate
```

### Convenience Functions

For more readability, you can use XmlBuilder's methods instead of creating tuples manually.

```elixir
XmlBuilder.document(:person, "Josh") |> XmlBuilder.generate
```

Outputs:

```xml
<?xml version="1.0" encoding="UTF-8" ?>
<person>Josh</person>
```

#### Building up an element

An element can be built using multiple calls to the `element` function.

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

Outputs.

```xml
<person id="123">
  <first>Steve</first>
  <last>Jobs</last>
</person>
<person id="456">
  <first>Steve</first>
  <last>Wozniak</last>
</person>
```

#### Using keyed lists

The previous example can be simplified using a keyed list.

```elixir
import XmlBuilder

def person(id, first, last) do
  element(:person, %{id: id}, first: first,
                              last: last)
end

iex> person(123, "Josh", "Nussbaum") |> generate(format: :none)
"<person id=\"123\"><first>Josh</first><last>Nussbaum</last></person>"
```

#### Namespaces

To use a namespace, add an `xmlns` attribute to the root element.

To use multiple schemas, specify a `xmlns:nsName` attribute for each schema and use a colon `:` in the element name, ie `nsName:elementName`.

```elixir
import XmlBuilder

iex> generate({:example, [xmlns: "http://schemas.example.tld/1999"], "content"})
"<example xmlns=\"http://schemas.example.tld/1999\">content</example>"

iex> generate({:"nsName:elementName", ["xmlns:nsName": "http://schemas.example.tld/1999"], "content"})
"<nsName:elementName xmlns:nsName=\"http://schemas.example.tld/1999\">content</nsName:elementName>"
```

### DOCTYPE declarations

A DOCTYPE can be declared by applying the `doctype` function at the first position of a list of elements in a `document` definition:

```elixir
import XmlBuilder

document([
  doctype("html", public: ["-//W3C//DTD XHTML 1.0 Transitional//EN",
                "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"]),
  element(:html, "Hello, world!")
]) |> generate
```

Outputs.

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>Hello, world!</html>
```

### Encoding

While the output is always UTF-8 and has to be converted in another place, you can override the encoding statement in the XML declaration with the `encoding` option.

```elixir
import XmlBuilder

document(:oldschool)
|> generate(encoding: "ISO-8859-1")
|> :unicode.characters_to_binary(:unicode, :latin1)
```

Outputs.

```xml
<?xml version="1.0" encoding="ISO-8859-1"?>
<oldschool/>
```

### Standalone

Should you need `standalone="yes"` in the XML declaration, you can pass `standalone: true` as option to the `generate/2` call.

```elixir
import XmlBuilder

document(:outsider)
|> generate(standalone: true)
```

Outputs.

```xml
<?xml version="1.0" standalone="yes"?>
<outsider/>
```

### Formatting

To remove indentation, pass `format: :none` option to `XmlBuilder.generate/2`.

```elixir
doc |> XmlBuilder.generate(format: :none)
```

The default is to formatting with indentation, which is equivalent to `XmlBuilder.generate(doc, format: :indent)`.

## License

This source code is licensed under the [MIT License](https://github.com/joshnuss/xml_builder/blob/master/LICENSE). Copyright (c) 2014-present, Joshua Nussbaum. All rights reserved.
