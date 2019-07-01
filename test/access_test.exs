defmodule XmlBuilder.Access.Test do
  use ExUnit.Case, async: true
  doctest XmlBuilder.Access

  import XmlBuilder,
    only: [doc: 1, doc: 2, doc: 3, document: 1, document: 2, document: 3, doctype: 2]

  setup_all do
    [
      person:
        {:person, %{id: 12345},
         [
           {:first, %{}, "Josh"},
           {:last, %{}, "Nussbaum"},
           {:first, %{}, "Jane"},
           {:last, %{}, "Doe"},
           {:subperson, %{class: "nested"},
            [
              {:first, %{}, "John"},
              {:last, %{}, "Doe"}
            ]}
         ]}
    ]
  end

  test "get_in/2", %{person: person} do
    assert get_in(person, [
             XmlBuilder.Access.key(:subperson),
             XmlBuilder.Access.key(:first)
           ]) == {:first, %{}, "John"}

    assert get_in(person, [XmlBuilder.Access.key({:last, 1})]) == {:last, %{}, "Doe"}
    assert get_in(person, [XmlBuilder.Access.key({:last, -1})]) == {:last, %{}, "Doe"}
    assert get_in(person, [XmlBuilder.Access.key({:last, -2})]) == {:last, %{}, "Nussbaum"}
    assert get_in(person, [XmlBuilder.Access.key({:last, -3})]) == nil
  end

  test "put_in/2", %{person: person} do
    assert put_in(
             person,
             [
               XmlBuilder.Access.key(:subperson),
               XmlBuilder.Access.key(:first)
             ],
             "Mary"
           ) ==
             {:person, %{id: 12345},
              [
                {:first, %{}, "Josh"},
                {:last, %{}, "Nussbaum"},
                {:first, %{}, "Jane"},
                {:last, %{}, "Doe"},
                {:subperson, %{class: "nested"}, [{:first, %{}, "Mary"}, {:last, %{}, "Doe"}]}
              ]}

    assert put_in(person, [XmlBuilder.Access.key({:first, 1})], "Mary") ==
             {:person, %{id: 12345},
              [
                {:first, %{}, "Josh"},
                {:last, %{}, "Nussbaum"},
                {:first, %{}, "Mary"},
                {:last, %{}, "Doe"},
                {:subperson, %{class: "nested"}, [{:first, %{}, "John"}, {:last, %{}, "Doe"}]}
              ]}

    assert put_in(person, [XmlBuilder.Access.key({:first, -1})], "Mary") ==
             {:person, %{id: 12345},
              [
                {:first, %{}, "Josh"},
                {:last, %{}, "Nussbaum"},
                {:first, %{}, "Mary"},
                {:last, %{}, "Doe"},
                {:subperson, %{class: "nested"}, [{:first, %{}, "John"}, {:last, %{}, "Doe"}]}
              ]}

    assert put_in(person, [XmlBuilder.Access.key({:first, 2})], "Mary") ==
             {:person, %{id: 12345},
              [
                {:first, %{}, "Josh"},
                {:last, %{}, "Nussbaum"},
                {:first, %{}, "Jane"},
                {:last, %{}, "Doe"},
                {:subperson, %{class: "nested"}, [{:first, %{}, "John"}, {:last, %{}, "Doe"}]},
                {:first, %{id: 12345}, "Mary"}
              ]}
  end
end
