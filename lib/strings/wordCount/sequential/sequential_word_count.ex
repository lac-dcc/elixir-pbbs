defmodule Strings.WordCount do
  def word_count(string) do
    String.split(string, ~r/[^A-z]+/)
    |> Enum.map(&String.downcase/1)
    |> Enum.frequencies()
  end
end
