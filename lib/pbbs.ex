
import Sequences.RadixSort

defmodule PBBS do
  @invalid_input_string "Invalid input: "

  def main(args) do
    # Check if input is valid
    if length(args) > 0 do
      # Getting the algorithm name and args by head and tail
      [method_name | method_args] = args
      # Case statement to choose which method needs to be called
      case method_name do
        "RadixSort" -> radix_sort(method_args)
        _ -> IO.puts(@invalid_input_string <> "algorithm name is invalid.")
      end
    else
      IO.puts(@invalid_input_string <> "first argument need to be the algorithm name.")
    end
  end
end
