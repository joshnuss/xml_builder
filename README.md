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

For more readability, you dont need to create tuples manually, use XmlBuilder's convenience methods instead.

```elixir
XmlBuilder.doc(:person, "Josh")
```

### Complex element

A complex element is just a simple element whose content is a list. You can build a complex element manually or by using the element function:

```elixir
import XmlBuilder

def person(id, first, last) do
  element(:person, %{id: id},[
    element(:first, first),
    element(:last, last)
  ])
end
```

## Examples

```elixir
IO.puts XmlBuilder.doc(:person)
#=> <?xml version="1.0">
    <person/>
 
IO.puts XmlBuilder.doc(:person, "Josh")
#=> <?xml version="1.0">
    <person>Josh</person>
 
IO.puts XmlBuilder.doc(:person, %{location: "Montreal", occupation: "Developer"})
#=> <?xml version="1.0">
    <person location="Montreal" occupation="Developer"/>
 
IO.puts XmlBuilder.doc(:person, %{location: "Montreal", occupation: "Developer"}, "Josh")
#=> <?xml version="1.0">
    <person location="Montreal" occupation="Developer">Josh</person>
 
IO.puts XmlBuilder.doc(:person, [
    {:name, "Josh"},
    {:occupation, "Developer"}
  ])
#=> <?xml version="1.0">
    <person>
      <name>Josh</name>
      <occupation>Developer</occupation>
    </person>
 
IO.puts XmlBuilder.doc(:person, %{id: 1234}, [
    {:name, "Josh"},
    {:occupation, "Developer"}
  ])
#=> <?xml version="1.0">
    <person id="1234">
      <name>Josh</name>
      <occupation>Developer</occupation>
    </person>
 
IO.puts XmlBuilder.doc([
    {:fruit, "Apple"},
    {:fruit, "Kiwi"},
    {:fruit, "Strawberry"}
  ])
#=> <?xml version="1.0">
    <fruit>Apple</fruit>
    <fruit>Kiwi</fruit>
    <fruit>Strawberry</fruit>
 
# same as previous
IO.puts XmlBuilder.doc(
    fruit: "Apple",
    fruit: "Kiwi",
    fruit: "Strawberry")
#=> <?xml version="1.0">
    <fruit>Apple</fruit>
    <fruit>Kiwi</fruit>
    <fruit>Strawberry</fruit>
```
