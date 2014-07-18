XML Builder
=======

Elixir library for building xml.

## Overview

Each xml node is structured as a tuple of name, attributes map and content/list:

```elixir
{name, attrs, content | list}

# to define the xml <person>Josh</person>, you would need a tuple like:
{:person, %{id: 12345}, "Josh"}

# to define a list of elements: <person><first>Josh</first><last>Nussbaum</last></person>
{:person, %{id: 12345}, [{:first, nil, "Josh"}, {:last, nil, "Nussbaum"}]}

# To make things more readable, you dont need to create the tuples manually, just use XmlBuilder's convenience methods instead.

# this results in <?xml version="1.0"><person>Josh</person>
XmlBuilder.doc(:person, "Josh")

# you can build a complex element, using the element function:
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
