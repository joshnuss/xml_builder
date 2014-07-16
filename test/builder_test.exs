defmodule BuilderTest do
  use ExUnit.Case

  test "empty element" do
    assert Builder.xml(:person) == "<person/>"
  end

  test "element with content" do
    assert Builder.xml(:person, "Josh") == "<person>Josh</person>"
  end
end
