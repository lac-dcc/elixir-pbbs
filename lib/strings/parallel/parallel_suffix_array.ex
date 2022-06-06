# Description: https://www.cs.cmu.edu/~pbbs/benchmarks/suffixArray.html

defmodule ParallelSuffixArray do
  # WIP
  defp split_segment_top(cl, n) do
    ranks = List.duplicate(0, n)
    #seg_outs = List.duplicate(0, n)

    #names = List.duplicate(0, n)
    mask = Bitwise.<<<(1, 32) - 1

    names = Enum.map(1..n, fn i ->
      if Bitwise.<<<(Enum.at(cl, i), 32) != Bitwise.<<<(Enum.at(cl, i - 1), 32) do
        i
      else
        0
      end
    end)
    names = [0 | names]

    names = Enum.scan(names, fn a, b ->
      Kernel.max(a, b)
    end)

    #C = List.duplicate({}, n)
    indexes = Enum.map(cl, fn i ->
      Bitwise.band(i, mask)
    end)
    |> MapSet.new()

    ranks = ranks
    |> Enum.with_index
    |> Enum.map(fn ({el, i}) ->
      if MapSet.member?(indexes, i) do
        Enum.at(names, i) + 1
      else
        el
      end
    end)

    output = Enum.map(0..n, fn i ->
      {elem(Enum.at(C, i), 0), Bitwise.band(Enum.at(cl, i), mask)}
    end)

    segOut = Enum.map(1..n, fn i ->
      if Enum.at(names, i) == i do
        v = Enum.at(names, i - 1)
        {v, i - v}
      else
        {0, 0}
      end
    end)

    vlast = Enum.at(names, n-1)
    segOut = segOut ++ [ {vlast, n - vlast}]

    {output, segOut, ranks}

  end
  def suffix_array(s) do
    n = String.length(s)
    pad = 48

    code_points = s
    |> to_charlist()
    |> MapSet.new()

    flags = Enum.map(0..256, fn i ->
      if MapSet.member?(code_points, i) do
        1
      else
        0
      end
    end)

    m = Enum.reduce(flags, 1, fn i, acc ->
      if i == 1 do
        acc + 1
      else
        acc
      end
    end)

    # scan
    flags = Enum.reduce(1..257, [1], fn i, acc ->
      if Enum.at(flags, i) == 1 do
        acc ++ [List.last(acc) + 1]
      else
        acc ++ [
          List.last(acc)
        ]
      end
    end)

    s = flags ++ List.duplicate(0, pad)

    logm = :math.log2(m)
    nchars = :math.floor(96.0 / logm)

    # pack
    cl = Enum.map(0..256, fn i ->
      r = Enum.at(s, i)

      r = Enum.reduce(1..nchars, r, fn j, acc ->
        acc * m + Enum.at(s, i + j)
      end)

      Bitwise.<<<(r, 32) + i
    end)

    cl = Enum.sort(cl)
    c = split_segment_top(cl, n)

    offset = nchars
    rd = 0
    nKeys = n

    # TODO: body of loop


  end
end
