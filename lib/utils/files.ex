defmodule Utils.Files do
  # This works but will break for some invalid file formats, so need to be corrected
  # And this method is very big and ugly, it needs to be refactored
  def get_pbbs_sequence(file_name) do
    {status, file_content} = File.read(file_name)

    if status == :ok do
      IO.puts("File found locally, trying to get the sequence...")
      get_pbbs_sequence_from_content(file_content)
    else
      IO.puts("File not found locally, trying to get via HTTP GET request...")

      return =
        case HTTPoison.get(file_name) do
          {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
            IO.puts("GET request works!")
            get_pbbs_sequence_from_content(body)

          {:ok, %HTTPoison.Response{status_code: 404}} ->
            IO.puts("Not found :(")

          {:error, %HTTPoison.Error{reason: reason}} ->
            IO.puts("GET request fails: ")
            IO.inspect(reason)
        end

      return
    end
  end

  defp get_pbbs_sequence_from_content(file_content) do
    string_list = String.split(file_content, ["\t", " ", "\n", "\r"])
    [sequence_type | elements] = Enum.filter(string_list, fn x -> x != "" end)

    if String.starts_with?(sequence_type, "sequence") do
      type = String.replace_prefix(sequence_type, "sequence", "")

      if String.ends_with?(type, "Pair") do
        pair = String.replace_suffix(type, "Pair", "")
        [type_1, type_2] = String.split(Macro.underscore(pair), "_")
        pairs_list = Enum.chunk_every(elements, 2)

        Enum.map(
          pairs_list,
          fn x ->
            [element_1 | [element_2]] = x

            a =
              case type_1 do
                "int" -> String.to_integer(element_1)
                "double" -> String.to_float(element_1)
                "string" -> element_1
                _ -> nil
              end

            b =
              case type_2 do
                "int" -> String.to_integer(element_2)
                "double" -> String.to_float(element_2)
                "string" -> element_2
                _ -> nil
              end

            {a, b}
          end
        )
      else
        case type do
          "Int" -> Enum.map(elements, fn x -> String.to_integer(x) end)
          "Double" -> Enum.map(elements, fn x -> String.to_float(x) end)
          "String" -> elements
          _ -> []
        end
      end
    else
      []
    end
  end
end
