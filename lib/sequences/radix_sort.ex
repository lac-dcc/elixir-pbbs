# Description: https://www.cs.cmu.edu/~pbbs/benchmarks/integerSort.html

defmodule Sequences.RadixSort do
  def radix_sort([n]) when is_binary(n) do
    if Utils.Validators.is_string_a_number(n) do
      radix_sort(String.to_integer(n))
    else
      list = Utils.Files.get_pbbs_sequence(n)
      if list != [] do
        sort(list)
      else
        display_error_message()
      end
    end
  end

  def radix_sort(n) when is_integer(n) do
    list = Utils.Generators.random_sequence(n)
    sort(list)
  end

  def radix_sort([m, n]) when is_binary(m) and is_binary(n) do
    if Utils.Validators.is_string_a_number(m) and Utils.Validators.is_string_a_number(n) do
      radix_sort(String.to_integer(m), String.to_integer(n))
    else
      display_error_message()
    end
  end

  def radix_sort(m, n) when is_integer(m) and is_integer(n) do
    list = Utils.Generators.random_sequence(m, n)
    sort(list)
  end

  defp sort(list) when is_list(list) do
    # work in progress
    IO.inspect(list)
  end

  defp display_error_message() do
    # Doubt: Did I need to check the number of threads?
    IO.puts("\nSyntax: ")
    IO.puts("escripts pbbs RadixSort [<m>] n")
    IO.puts("   to sort n values in a range [0, m] OR\n")
    IO.puts("escripts pbbs RadixSort IN")
    IO.puts("   IN: input file with numbers to sort (in the PBBS format).")
  end
end
