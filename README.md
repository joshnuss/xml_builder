XML XmlBuilder
=======

Elixir library for building xml

```elixir
IO.puts XmlBuilder.doc(:person)
#=> "<person/>"
 
IO.puts XmlBuilder.doc(:person, "Josh")
#=> "<person>Josh</person>"
 
IO.puts XmlBuilder.doc(:person, %{location: "Montreal", occupation: "Developer"})
#=> "<person location="Montreal" occupation="Developer"/>"
 
IO.puts XmlBuilder.doc(:person, %{location: "Montreal", occupation: "Developer"}, "Josh")
#=> "<person location="Montreal" occupation="Developer">Josh</person>"
 
IO.puts XmlBuilder.doc(:person, [
    {:name, "Josh"},
    {:occupation, "Developer"}
  ])
#=> "<person><name>Josh</name><occupation>Developer</occupation></person>"
 
IO.puts XmlBuilder.doc(:person, %{id: 1234}, [
    {:name, "Josh"},
    {:occupation, "Developer"}
  ])
#=> "<person id="1234"><name>Josh</name><occupation>Developer</occupation></person>"
 
IO.puts XmlBuilder.doc([
    {:fruit, "Apple"},
    {:fruit, "Kiwi"},
    {:fruit, "Strawberry"}
  ])
#=> "<fruit>Apple</fruit><fruit>Kiwi</fruit><fruit>Strawberry</fruit>"
 
# same as previous
IO.puts XmlBuilder.doc(
    fruit: "Apple",
    fruit: "Kiwi",
    fruit: "Strawberry")
#=> "<fruit>Apple</fruit><fruit>Kiwi</fruit><fruit>Strawberry</fruit>"
```

## Todo
- better wrapping double vs. single quote, use escaping when neccesary
- add doctype
- add optional indentation
