defmodule BuilderTest do
  use ExUnit.Case

  test "empty element" do
    assert Builder.xml(:person) == "<person/>"
  end
end
