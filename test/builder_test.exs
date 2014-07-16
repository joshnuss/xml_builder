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

  test "element with attributes and content" do
    assert Builder.xml(:person, %{occupation: "Developer", city: "Montreal"}, "Josh") == ~s|<person city="Montreal" occupation="Developer">Josh</person>|
    assert Builder.xml(:person, %{occupation: "Developer", city: "Montreal"}, nil) == ~s|<person city="Montreal" occupation="Developer"/>|
    assert Builder.xml(:person, %{}, "Josh") == "<person>Josh</person>"
    assert Builder.xml(:person, %{}, nil) == "<person/>"
  end

  test "element with children" do
    assert Builder.xml(:person, [{:name, %{id: 123}, "Josh"}]) == ~s|<person><name id="123">Josh</name></person>|
    assert Builder.xml(:person, [{:first_name, "Josh"}, {:last_name, "Nussbaum"}]) == ~s|<person><first_name>Josh</first_name><last_name>Nussbaum</last_name></person>|
  end

  test "element with attributes and children" do
    assert Builder.xml(:person, %{id: 123}, [{:name, "Josh"}]) == ~s|<person id="123"><name>Josh</name></person>|
    assert Builder.xml(:person, %{id: 123}, [{:first_name, "Josh"}, {:last_name, "Nussbaum"}]) == ~s|<person id="123"><first_name>Josh</first_name><last_name>Nussbaum</last_name></person>|
  end

  test "children elements" do
    assert Builder.xml([{:name, %{id: 123}, "Josh"}]) == ~s|<name id="123">Josh</name>|
    assert Builder.xml([{:first_name, "Josh"}, {:last_name, "Nussbaum"}]) == ~s|<first_name>Josh</first_name><last_name>Nussbaum</last_name>|
  end
end
