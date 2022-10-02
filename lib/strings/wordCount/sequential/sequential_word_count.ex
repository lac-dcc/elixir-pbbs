defmodule Strings.WordCount do
  def word_count(string) do
    String.split(string)
    |> Enum.frequencies()
  end
end
