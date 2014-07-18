XML Builder
=======

Elixir library for building xml

```elixir
IO.puts XmlBuilder.doc(:person)
#=> <?xml version="1.0"><person/>
 
IO.puts XmlBuilder.doc(:person, "Josh")
#=> <?xml version="1.0"><person>Josh</person>
 
IO.puts XmlBuilder.doc(:person, %{location: "Montreal", occupation: "Developer"})
#=> <?xml version="1.0"><person location="Montreal" occupation="Developer"/>
 
IO.puts XmlBuilder.doc(:person, %{location: "Montreal", occupation: "Developer"}, "Josh")
#=> <?xml version="1.0"><person location="Montreal" occupation="Developer">Josh</person>
 
IO.puts XmlBuilder.doc(:person, [
    {:name, "Josh"},
    {:occupation, "Developer"}
  ])
#=> <?xml version="1.0"><person><name>Josh</name><occupation>Developer</occupation></person>
 
IO.puts XmlBuilder.doc(:person, %{id: 1234}, [
    {:name, "Josh"},
    {:occupation, "Developer"}
  ])
#=> <?xml version="1.0"><person id="1234"><name>Josh</name><occupation>Developer</occupation></person>
 
IO.puts XmlBuilder.doc([
    {:fruit, "Apple"},
    {:fruit, "Kiwi"},
    {:fruit, "Strawberry"}
  ])
#=> <?xml version="1.0"><fruit>Apple</fruit><fruit>Kiwi</fruit><fruit>Strawberry</fruit>
 
# same as previous
IO.puts XmlBuilder.doc(
    fruit: "Apple",
    fruit: "Kiwi",
    fruit: "Strawberry")
#=> <?xml version="1.0"><fruit>Apple</fruit><fruit>Kiwi</fruit><fruit>Strawberry</fruit>
```
