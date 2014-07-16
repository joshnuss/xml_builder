XML Builder
=======

Elixir library for building xml

```elixir
IO.puts Builder.xml(:person)
#=> "<person/>"
 
IO.puts Builder.xml(:person, "Josh")
#=> "<person>Josh</person>"
 
IO.puts Builder.xml(:person, %{location: "Montreal", occupation: "Developer"})
#=> "<person location="Montreal" occupation="Developer"/>"
 
IO.puts Builder.xml(:person, %{location: "Montreal", occupation: "Developer"}, "Josh")
#=> "<person location="Montreal" occupation="Developer">Josh</person>"
 
IO.puts Builder.xml(:person, [
    {:name, "Josh"},
    {:occupation, "Developer"}
  ])
#=> "<person><name>Josh</name><occupation>Developer</occupation></person>"
 
IO.puts Builder.xml(:person, %{id: 1234}, [
    {:name, "Josh"},
    {:occupation, "Developer"}
  ])
#=> "<person id="1234"><name>Josh</name><occupation>Developer</occupation></person>"
 
IO.puts Builder.xml([
    {:fruit, "Apple"},
    {:fruit, "Kiwi"},
    {:fruit, "Strawberry"}
  ])
#=> "<fruit>Apple</fruit><fruit>Kiwi</fruit><fruit>Strawberry</fruit>"
 
# same as previous
IO.puts Builder.xml(
    fruit: "Apple",
    fruit: "Kiwi",
    fruit: "Strawberry")
#=> "<fruit>Apple</fruit><fruit>Kiwi</fruit><fruit>Strawberry</fruit>"
```
