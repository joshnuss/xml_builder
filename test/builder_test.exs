defmodule BuilderTest do
  use ExUnit.Case

  test "empty element" do
    assert Builder.xml(:person) == "<person/>"
  end

  test "element with content" do
    assert Builder.xml(:person, "Josh") == "<person>Josh</person>"
  end

  test "element with attributes" do
    assert Builder.xml(:person, %{occupation: "Developer", city: "Montreal"}) == ~s|<person city="Montreal" occupation="Developer"/>|
    assert Builder.xml(:person, %{}) == ~s|<person/>|
  end
end
