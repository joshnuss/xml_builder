defmodule XmlBuilderTest do
  use ExUnit.Case
  doctest XmlBuilder

  def document(name),
    do: XmlBuilder.doc(name) |> XmlBuilder.generate

  def document(name, arg),
    do: XmlBuilder.doc(name, arg) |> XmlBuilder.generate

  def document(name, attrs, content),
    do: XmlBuilder.doc(name, attrs, content) |> XmlBuilder.generate

  def element(name, arg),
    do: XmlBuilder.element(name, arg) |> XmlBuilder.generate

  def element(name, attrs, content),
    do: XmlBuilder.element(name, attrs, content) |> XmlBuilder.generate

  test "empty element" do
    assert document(:person) == ~s|<?xml version="1.0"><person/>|
  end

  test "element with content" do
    assert document(:person, "Josh") == ~s|<?xml version="1.0"><person>Josh</person>|
  end

  test "element with attributes" do
    assert document(:person, %{occupation: "Developer", city: "Montreal"}) == ~s|<?xml version="1.0"><person city="Montreal" occupation="Developer"/>|
    assert document(:person, %{}) == ~s|<?xml version="1.0"><person/>|
  end

  test "element with attributes and content" do
    assert document(:person, %{occupation: "Developer", city: "Montreal"}, "Josh") == ~s|<?xml version="1.0"><person city="Montreal" occupation="Developer">Josh</person>|
    assert document(:person, %{occupation: "Developer", city: "Montreal"}, nil) == ~s|<?xml version="1.0"><person city="Montreal" occupation="Developer"/>|
    assert document(:person, %{}, "Josh") == ~s|<?xml version="1.0"><person>Josh</person>|
    assert document(:person, %{}, nil) == ~s|<?xml version="1.0"><person/>|
  end

  test "element with children" do
    assert document(:person, [{:name, %{id: 123}, "Josh"}]) == ~s|<?xml version="1.0"><person><name id="123">Josh</name></person>|
    assert document(:person, [{:first_name, "Josh"}, {:last_name, "Nussbaum"}]) == ~s|<?xml version="1.0"><person><first_name>Josh</first_name><last_name>Nussbaum</last_name></person>|
  end

  test "element with attributes and children" do
    assert document(:person, %{id: 123}, [{:name, "Josh"}]) == ~s|<?xml version="1.0"><person id="123"><name>Josh</name></person>|
    assert document(:person, %{id: 123}, [{:first_name, "Josh"}, {:last_name, "Nussbaum"}]) == ~s|<?xml version="1.0"><person id="123"><first_name>Josh</first_name><last_name>Nussbaum</last_name></person>|
  end

  test "children elements" do
    assert document([{:name, %{id: 123}, "Josh"}]) == ~s|<?xml version="1.0"><name id="123">Josh</name>|
    assert document([{:first_name, "Josh"}, {:last_name, "Nussbaum"}]) == ~s|<?xml version="1.0"><first_name>Josh</first_name><last_name>Nussbaum</last_name>|
  end

  test "quoting and escaping attributes" do
    assert element(:person, %{height: 12}) == ~s|<person height="12"/>|
    assert element(:person, %{height: ~s|10'|}) == ~s|<person height="10'"/>|
    assert element(:person, %{height: ~s|10"|}) == ~s|<person height='10"'/>|
    assert element(:person, %{height: ~s|<10'5"|}) == ~s|<person height="&lt;10'5&quot;"/>|
  end

  test "escaping content" do
    assert element(:person, "Josh") == "<person>Josh</person>"
    assert element(:person, "<Josh>") == "<person>&lt;Josh&gt;</person>"
  end
end
