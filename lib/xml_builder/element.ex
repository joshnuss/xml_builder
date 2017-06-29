defmodule XmlBuilder.Element do
  @typedoc """
  The XML element internal representation.
  """
  @type t :: %__MODULE__{
    name: bitstring | String.t | nil,
    attrs: Map.t,
    content: Tuple.t | String.t | List.t | nil}

  defstruct name: nil, attrs: %{}, content: nil

  def to_tuple(element), do: {element.name, element.attrs, element.content}

  def to_element(name) when is_bitstring(name),
    do: to_element({nil, nil, name})

  def to_element(name) when is_bitstring(name) or is_atom(name),
    do: to_element({name})

  def to_element({name}),
    do: to_element({name, nil, nil})

  def to_element({name, %{} = attrs}),
    do: to_element({name, attrs, nil})

  def to_element({name, content}),
    do: to_element({name, nil, content})

  def to_element(name, %{} = attrs),
    do: to_element({name, attrs, nil})

  def to_element(name, content),
    do: to_element({name, nil, content})

  def to_element(name, attrs, content),
    do: to_element({name, attrs, content})

  def to_element(list) when is_list(list),
    do: Enum.map(list, &to_element/1)

  def to_element({name, attrs, content}) when is_list(content) do
    %XmlBuilder.Element{name: name, attrs: attrs, content: Enum.map(content, &to_element/1)}
    |> XmlBuilder.Element.to_tuple()
  end

  def to_element({name, attrs, content}) do
    %XmlBuilder.Element{name: name, attrs: attrs, content: content}
    |> XmlBuilder.Element.to_tuple()
  end

end
