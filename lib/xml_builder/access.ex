defmodule XmlBuilder.Access do
  @moduledoc """
  Provides a function-based `Access` implementation. This allows to get an access
  to deeply nested elemetns via `Kernel.get_in/2`, `Kernel.put_in/3`,
  `Kernel.update_in/3`, and `Kernel.get_and_update_in/3`.

  **Example:**
      iex> get_in({:person, %{id: 1}, [{:data, %{}, [{:name, %{}, "John"}]}]},
      ...>   [XmlBuilder.Access.key(:data), XmlBuilder.Access.key(:name), XmlBuilder.Access.key()])
      "John"

      iex> get_in({:persons, %{}, [{:name, %{}, "John"}, {:name, %{}, "Jane"}]},
      ...>   [XmlBuilder.Access.key({:name, -1}), XmlBuilder.Access.key()])
      "Jane"

  Negative indices are supported, `-1` for the last element, `-2` for next to the last etc.

  """

  @typedoc """
  Nested elements of any node are in general accessible by `{name, index}` tuple.
  When a single name atom passed as an argument, the implementation assumes
  index zero.
  """
  @type maybe_ordered_key ::
          nil | atom() | {atom(), integer() | :append | :prepend}

  @doc """
  Default `Access` function implementation accepting default values.

  **Examples:**

      iex> # simple value
      iex> get_in({:person, %{id: 1}, 42}, [XmlBuilder.Access.key()])
      42
      iex> put_in({:person, %{id: 1}, nil}, [XmlBuilder.Access.key()], 42)
      {:person, %{id: 1}, 42}
      iex> update_in({:person, %{id: 1}, nil},
      ...>   [XmlBuilder.Access.key()], fn _ -> 42 end)
      {:person, %{id: 1}, 42}
      iex> get_and_update_in({:person, %{id: 1}, nil},
      ...>   [XmlBuilder.Access.key()], fn old -> {old, 42} end)
      {nil, {:person, %{id: 1}, 42}}

      iex> # nested element
      iex> get_in({:person, %{id: 1}, [{:name, %{}, "John"}]},
      ...>   [XmlBuilder.Access.key(:name)])
      {:name, %{}, "John"}
      iex> put_in({:person, %{id: 1}, [{:name, %{}, "John"}]},
      ...>   [XmlBuilder.Access.key(:name)], "Mary")
      {:person, %{id: 1}, [{:name, %{}, "Mary"}]}
      iex> update_in({:person, %{id: 1}, [{:name, %{}, "John"}]},
      ...>   [XmlBuilder.Access.key(:name)], fn _ -> "Mary" end)
      {:person, %{id: 1}, [{:name, %{}, "Mary"}]}
      iex> get_and_update_in({:person, %{id: 1}, [{:name, %{}, "John"}]},
      ...>   [XmlBuilder.Access.key(:name)], fn {_, _, old} -> {old, "Mary"} end)
      {"John", {:person, %{id: 1}, [{:name, %{}, "Mary"}]}}

  """
  @spec key(
          key :: maybe_ordered_key(),
          opts :: keyword()
        ) :: any | {any(), any()}

  def key(key \\ nil, opts \\ [])

  def key(nil, _opts) do
    fn
      :get, {_name, _attrs, value}, fun ->
        fun.(value)

      :get_and_update, {name, attrs, value}, fun ->
        case fun.(value) do
          :pop ->
            {value, {name, attrs, nil}}

          {old, updated} ->
            {old, {name, attrs, updated}}
        end
    end
  end

  def key(key, opts) when is_atom(key), do: key({key, 0}, opts)

  def key({key, index}, _opts) when is_atom(key) and is_integer(index) do
    fn
      :get, {_name, _attrs, value}, fun when is_list(value) ->
        {value, idx} = if index < 0, do: {Enum.reverse(value), -index - 1}, else: {value, index}

        with {^key, attrs, value} <-
               value
               |> Enum.reduce_while({0, nil}, fn
                 {^key, _, _} = e, {^idx, nil} -> {:halt, {idx, e}}
                 {^key, _, _}, {idx, nil} -> {:cont, {idx + 1, nil}}
                 _, acc -> {:cont, acc}
               end)
               |> elem(1) do
          value = if index < 0 and is_list(value), do: Enum.reverse(value), else: value

          fun.({key, attrs, value})
        else
          nil -> fun.(nil)
        end

      :get_and_update, {name, attrs, value}, fun when is_list(value) ->
        {value, idx} = if index < 0, do: {Enum.reverse(value), -index - 1}, else: {value, index}

        {updated_at, {old, updated}} =
          Enum.reduce(value, {0, {nil, []}}, fn
            {^key, attrs, value}, {^idx, {nil, acc}} ->
              updated =
                case fun.({key, attrs, value}) do
                  :pop -> {{key, attrs, value}, acc}
                  {old, {key, attrs, updated}} -> {old, [{key, attrs, updated} | acc]}
                  {old, updated} -> {old, [{key, attrs, updated} | acc]}
                end

              {idx + 1, updated}

            {^key, _, _} = matched, {idx, {value, acc}} ->
              {idx + 1, {value, [matched | acc]}}

            any, {idx, {value, acc}} ->
              {idx, {value, [any | acc]}}
          end)

        updated = if index >= 0, do: Enum.reverse(updated), else: updated

        if updated_at > idx do
          {old, {name, attrs, updated}}
        else
          {old_value, updated_value} =
            case fun.({key, attrs, nil}) do
              :pop -> {{key, attrs, nil}, []}
              {old, {key, attrs, updated}} -> {old, [{key, attrs, updated}]}
              {old, updated} -> {old, [{key, attrs, updated}]}
            end

          {old_value, {name, attrs, updated ++ updated_value}}
        end
    end
  end
end
