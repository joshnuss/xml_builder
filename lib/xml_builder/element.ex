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

  def as_tuple(name) when is_bitstring(name),
    do: as_tuple({nil, nil, name})

  def as_tuple(name) when is_bitstring(name) or is_atom(name),
    do: as_tuple({name})

  def as_tuple({name}),
    do: as_tuple({name, nil, nil})

  def as_tuple({name, %{} = attrs}),
    do: as_tuple({name, attrs, nil})

  def as_tuple({name, content}),
    do: as_tuple({name, nil, content})

  def as_tuple(name, %{} = attrs),
    do: as_tuple({name, attrs, nil})

  def as_tuple(name, content),
    do: as_tuple({name, nil, content})

  def as_tuple(name, attrs, content),
    do: as_tuple({name, attrs, content})

  def as_tuple(list) when is_list(list),
    do: Enum.map(list, &as_tuple/1)

  def as_tuple({name, attrs, content}) when is_list(content) do
    %XmlBuilder.Element{name: name, attrs: attrs, content: Enum.map(content, &as_tuple/1)}
    |> XmlBuilder.Element.to_tuple()
  end

  def as_tuple({name, attrs, content}) do
    %XmlBuilder.Element{name: name, attrs: attrs, content: content}
    |> XmlBuilder.Element.to_tuple()
  end

end
