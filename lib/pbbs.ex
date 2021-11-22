defmodule PBBS do
  @invalid_input_string "Invalid input: "

  def main(args) do
    if length(args) > 0 do
      [method_name | method_args] = args
      case method_name do
        "RadixSort" -> Sequences.RadixSort.run(method_args)
        "SampleSort" -> Sequences.SampleSort.sample_sort(method_args)
        _ -> IO.puts(@invalid_input_string <> "algorithm name is invalid.")
      end
    else
      IO.puts(@invalid_input_string <> "first argument need to be the algorithm name.")
    end
  end
end
