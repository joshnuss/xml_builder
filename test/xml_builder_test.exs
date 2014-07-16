defmodule XmlBuilderTest do
  use ExUnit.Case

  test "empty element" do
    assert XmlBuilder.doc(:person) == "<person/>"
  end

  test "element with content" do
    assert XmlBuilder.doc(:person, "Josh") == "<person>Josh</person>"
  end

  test "element with attributes" do
    assert XmlBuilder.doc(:person, %{occupation: "Developer", city: "Montreal"}) == ~s|<person city="Montreal" occupation="Developer"/>|
    assert XmlBuilder.doc(:person, %{}) == ~s|<person/>|
  end

  test "element with attributes and content" do
    assert XmlBuilder.doc(:person, %{occupation: "Developer", city: "Montreal"}, "Josh") == ~s|<person city="Montreal" occupation="Developer">Josh</person>|
    assert XmlBuilder.doc(:person, %{occupation: "Developer", city: "Montreal"}, nil) == ~s|<person city="Montreal" occupation="Developer"/>|
    assert XmlBuilder.doc(:person, %{}, "Josh") == "<person>Josh</person>"
    assert XmlBuilder.doc(:person, %{}, nil) == "<person/>"
  end

  test "element with children" do
    assert XmlBuilder.doc(:person, [{:name, %{id: 123}, "Josh"}]) == ~s|<person><name id="123">Josh</name></person>|
    assert XmlBuilder.doc(:person, [{:first_name, "Josh"}, {:last_name, "Nussbaum"}]) == ~s|<person><first_name>Josh</first_name><last_name>Nussbaum</last_name></person>|
  end

  test "element with attributes and children" do
    assert XmlBuilder.doc(:person, %{id: 123}, [{:name, "Josh"}]) == ~s|<person id="123"><name>Josh</name></person>|
    assert XmlBuilder.doc(:person, %{id: 123}, [{:first_name, "Josh"}, {:last_name, "Nussbaum"}]) == ~s|<person id="123"><first_name>Josh</first_name><last_name>Nussbaum</last_name></person>|
  end

  test "children elements" do
    assert XmlBuilder.doc([{:name, %{id: 123}, "Josh"}]) == ~s|<name id="123">Josh</name>|
    assert XmlBuilder.doc([{:first_name, "Josh"}, {:last_name, "Nussbaum"}]) == ~s|<first_name>Josh</first_name><last_name>Nussbaum</last_name>|
  end
end
