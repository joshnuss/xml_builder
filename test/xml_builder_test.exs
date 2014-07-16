defmodule XmlXmlBuilderTest do
  use ExUnit.Case

  test "empty element" do
    assert XmlBuilder.doc(:person) == ~s|<?xml version="1.0"><person/>|
  end

  test "element with content" do
    assert XmlBuilder.doc(:person, "Josh") == ~s|<?xml version="1.0"><person>Josh</person>|
  end

  test "element with attributes" do
    assert XmlBuilder.doc(:person, %{occupation: "Developer", city: "Montreal"}) == ~s|<?xml version="1.0"><person city="Montreal" occupation="Developer"/>|
    assert XmlBuilder.doc(:person, %{}) == ~s|<?xml version="1.0"><person/>|
  end

  test "element with attributes and content" do
    assert XmlBuilder.doc(:person, %{occupation: "Developer", city: "Montreal"}, "Josh") == ~s|<?xml version="1.0"><person city="Montreal" occupation="Developer">Josh</person>|
    assert XmlBuilder.doc(:person, %{occupation: "Developer", city: "Montreal"}, nil) == ~s|<?xml version="1.0"><person city="Montreal" occupation="Developer"/>|
    assert XmlBuilder.doc(:person, %{}, "Josh") == ~s|<?xml version="1.0"><person>Josh</person>|
    assert XmlBuilder.doc(:person, %{}, nil) == ~s|<?xml version="1.0"><person/>|
  end

  test "element with children" do
    assert XmlBuilder.doc(:person, [{:name, %{id: 123}, "Josh"}]) == ~s|<?xml version="1.0"><person><name id="123">Josh</name></person>|
    assert XmlBuilder.doc(:person, [{:first_name, "Josh"}, {:last_name, "Nussbaum"}]) == ~s|<?xml version="1.0"><person><first_name>Josh</first_name><last_name>Nussbaum</last_name></person>|
  end

  test "element with attributes and children" do
    assert XmlBuilder.doc(:person, %{id: 123}, [{:name, "Josh"}]) == ~s|<?xml version="1.0"><person id="123"><name>Josh</name></person>|
    assert XmlBuilder.doc(:person, %{id: 123}, [{:first_name, "Josh"}, {:last_name, "Nussbaum"}]) == ~s|<?xml version="1.0"><person id="123"><first_name>Josh</first_name><last_name>Nussbaum</last_name></person>|
  end

  test "children elements" do
    assert XmlBuilder.doc([{:name, %{id: 123}, "Josh"}]) == ~s|<?xml version="1.0"><name id="123">Josh</name>|
    assert XmlBuilder.doc([{:first_name, "Josh"}, {:last_name, "Nussbaum"}]) == ~s|<?xml version="1.0"><first_name>Josh</first_name><last_name>Nussbaum</last_name>|
  end

  test "quoting and escaping attributes" do
    assert XmlBuilder.element(:person, %{height: 12}) == ~s|<person height="12"/>|
    assert XmlBuilder.element(:person, %{height: ~s|10'|}) == ~s|<person height="10'"/>|
    assert XmlBuilder.element(:person, %{height: ~s|10"|}) == ~s|<person height='10"'/>|
    assert XmlBuilder.element(:person, %{height: ~s|<10'5"|}) == ~s|<person height="&lt;10'5&quot;"/>|
  end

  test "escaping content" do
    assert XmlBuilder.element(:person, "Josh") == "<person>Josh</person>"
    assert XmlBuilder.element(:person, "<Josh>") == "<person>&lt;Josh&gt;</person>"
  end
end
