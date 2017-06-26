defmodule XmlBuilder.Formatter do
  @callback format(String.t | List.t | Tuple.t, Integer.t) :: String.t

  defmacro __using__(opts) do
    quote do
      @behaviour XmlBuilder.Formatter

      @indenter unquote(opts[:indent]) || "\t"
      @intersperser unquote(opts[:intersperse]) || "\n"
      @blanker unquote(opts[:blank]) || ""

      defmacrop is_blank_attrs(attrs) do
        quote do: is_nil(unquote(attrs)) or map_size(unquote(attrs)) == 0
      end

      defmacrop is_blank_list(list) do
        quote do: is_nil(unquote(list)) or (is_list(unquote(list)) and length(unquote(list)) == 0)
      end


      def format(:_doc_type, 0),
        do: ~s|<?xml version="1.0" encoding="UTF-8"?>|

      def format(string, level) when is_bitstring(string),
        do: format({nil, nil, string}, level)

      def format(list, level) when is_list(list) do
        result = list |> Enum.map(&format(&1, level))
        case intersperse(:binary) do
          "" -> result
          _  -> Enum.intersperse(result, intersperse(:binary))
        end
      end

      def format({nil, nil, name}, level) when is_bitstring(name),
        do: [indent(level), to_string(name)]

      def format({name, attrs, content}, level) when is_blank_attrs(attrs) and is_blank_list(content),
        do: [indent(level), '<', to_string(name), '/>']

      def format({name, attrs, content}, level) when is_blank_list(content),
        do: [indent(level), '<', to_string(name), ' ', format_attributes(attrs), '/>']

      def format({name, attrs, content}, level) when is_blank_attrs(attrs) and not is_list(content),
        do: [indent(level), '<', to_string(name), '>', format_content(content, level+1), '</', to_string(name), '>']

      def format({name, attrs, content}, level) when is_blank_attrs(attrs) and is_list(content),
        do: [indent(level), '<', to_string(name), '>', format_content(content, level+1), intersperse(:bitstring), indent(level), '</', to_string(name), '>']

      def format({name, attrs, content}, level) when not is_blank_attrs(attrs) and not is_list(content),
        do: [indent(level), '<', to_string(name), ' ', format_attributes(attrs), '>', format_content(content, level+1), '</', to_string(name), '>']

      def format({name, attrs, content}, level) when not is_blank_attrs(attrs) and is_list(content),
        do: [indent(level), '<', to_string(name), ' ', format_attributes(attrs), '>', format_content(content, level+1), intersperse(:bitstring), indent(level), '</', to_string(name), '>']


      defp format_content(children, level) when is_list(children),
        do: [intersperse(:bitstring), Enum.map_join(children, intersperse(:binary), &format(&1, level))]

      defp format_content(content, _level),
        do: escape(content)

      defp format_attributes(attrs),
        do: Enum.map_join(attrs, " ", fn {name,value} -> [to_string(name), '=', quote_attribute_value(value)] end)


      defp quote_attribute_value(val) when not is_bitstring(val),
        do: quote_attribute_value(to_string(val))

      defp quote_attribute_value(val) do
        double = String.contains?(val, ~s|"|)
        single = String.contains?(val, "'")
        escaped = escape(val)

        cond do
          double && single ->
            escaped |> String.replace("\"", "&quot;") |> quote_attribute_value
          double -> "'#{escaped}'"
          true -> ~s|"#{escaped}"|
        end
      end

      defp escape({:cdata, data}) do
        ["<![CDATA[", data, "]]>"]
      end

      defp escape(data) when not is_bitstring(data),
        do: escape(to_string(data))

      defp escape(string) do
        string
        |> String.replace(">", "&gt;")
        |> String.replace("<", "&lt;")
        |> replace_ampersand
      end

      defp replace_ampersand(string) do
        Regex.replace(~r/&(?!lt;|gt;|quot;)/, string, "&amp;")
      end


      defp indent(level), do: String.duplicate(@indenter, level)
      defp intersperse(:binary), do: @intersperser
      defp intersperse(:bitstring), do: to_charlist(@intersperser)
      defp blank(:binary), do: @blanker
      defp blank(:bitstring), do: to_charlist(@blanker)

      defoverridable [indent: 1, intersperse: 1]
    end
  end

end
