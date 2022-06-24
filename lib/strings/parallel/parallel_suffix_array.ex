# Description: https://www.cs.cmu.edu/~pbbs/benchmarks/suffixArray.html

defmodule ParallelSuffixArray do
  defp split_segment_top(cl, n) do
    mask = Bitwise.<<<(1, 32) - 1

    names = Enum.map(1..(n-1), fn i ->
      if Bitwise.<<<(Enum.at(cl, i, 0), 32) != Bitwise.<<<(Enum.at(cl, i - 1, 0), 32) do
        i
      else
        0
      end
    end)
    names = [0 | names]

    names = Enum.scan(names, fn a, b ->
      Kernel.max(a, b)
    end)

    indexes = Enum.map(cl, fn i ->
      Bitwise.band(i, mask)
    end)


    ranks = indexes
    |> Enum.with_index
    |> Enum.map(fn ({val, idx}) ->
      {val, Enum.at(names, idx) + 1}
    end)
    |> Enum.sort_by(&elem(&1, 0))
    |> Enum.map(&elem(&1, 1))

    output = Enum.map(0..(n-1), fn i ->
      {0, Bitwise.band(Enum.at(cl, i), mask)}
    end)

    seg_out = Enum.map(1..(n-1), fn i ->
      if Enum.at(names, i) == i do
        v = Enum.at(names, i - 1)
        {v, i - v}
      else
        {0, 0}
      end
    end)

    vlast = Enum.at(names, n-1)
    seg_out = seg_out ++ [ {vlast, n - vlast}]

    {output, seg_out, ranks}
  end

  defp split_segment(seg_out, ranks, cl, start) do
    l = length(seg_out)

    names = Enum.map(1..l, fn i ->
      if Enum.at(cl, i) != Enum.at(cl, i - 1) do
        i
      else
        0
      end
    end)
    names = [0 | names]

    names = Enum.scan(names, fn a, b ->
      Kernel.max(a, b)
    end)

    indexes = 0..l
    |> Enum.map(fn i -> Enum.at(cl, i) end)
    |> MapSet.new

    ranks = ranks
    |> Enum.with_index
    |> Enum.map(fn ({el, i}) ->
      if MapSet.member?(indexes, i) do
        Enum.at(names, i) + start + 1
      else
        el
      end
    end)

    seg_out = Enum.map(0..l, fn i ->
      if i+1 >= 1 and i+1 <= l do
        if Enum.at(names, i+1) == i+1 do
          v = Enum.at(names, i)
          {start + v, (i+1) - v}
        else
          {0, 0}
        end
      else
        if i+1 == l do
          v = Enum.at(names, i)
          {start + v, (i+1) - v}
        end
        Enum.at(seg_out, i)
      end
    end)

    {seg_out, ranks}
  end

  def suffix_array(ss) do
    n = String.length(ss)
    pad = 48

    code_points = ss
    |> to_charlist()
    |> MapSet.new()

    flags = Enum.map(0..255, fn i ->
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
    flags = Enum.scan([1 | flags], &Kernel.+/2)
    |> Enum.slice(0..255)

    char_flags = Enum.map(String.to_charlist(ss), fn c ->
      Enum.at(flags, c)
    end)

    s = char_flags ++ List.duplicate(0, pad)

    logm = :math.log2(m)
    nchars = trunc(:math.floor(96.0 / logm))

    cl = Enum.map(0..(n-1), fn i ->
      r = Enum.at(s, i)

      r = Enum.reduce(1..(nchars - 1), r, fn j, acc ->
        (acc * m) + Enum.at(s, (i + j), 0)
      end)
      Bitwise.<<<(r, 32) + i
    end)


    cl = Enum.sort(cl)

    {c, seg_out, ranks} = split_segment_top(cl, n)

    offset = nchars
    nKeys = n

    IO.inspect("offset=#{offset}")
    IO.inspect("nkeys=#{nKeys}")

    {c, _ranks} = recursion(offset, 0, nKeys, c, seg_out, ranks, n)
    ranks = Enum.map(c, &elem(&1, 1))

    ranks
  end

  defp recursion(offset, rd, n_keys, c, seg_out, ranks, str_size) do
    if rd > 40 do
      raise "Suffix Array: internal error, too many rounds"
    end

    segs = Enum.slice(seg_out, 0..(n_keys - 1))
    |> Enum.map(&elem(&1, 1))
    |> Enum.filter(&Kernel.>(&1, 1))

    n_segs = length(segs)
    if n_segs == 0 do
      {c, ranks}
    else
      # TODO: verify the behavior of this else clause (maps to the main loop of the C++ code), as well as the split_segment function.
      offsets = Enum.map(segs, fn seg -> elem(seg, 1) end)

      # Step 1: cut
      ci = Enum.map(segs, fn seg ->
        start = elem(seg, 0)
        seg_len = elem(seg, 1)

        {start, Enum.slice(c, start..(start + seg_len))}
      end)

      # Step 2: 'update' first elem of tuple
      ci = Enum.map(ci, fn el_tuple ->
        idx = elem(el_tuple, 0)
        el = elem(el_tuple, 1)
        o = elem(el, 1) + offset
        if o >= str_size do
          {idx, {0, elem(el, 1)}}
        else
          {idx, {Enum.at(ranks, o), elem(el, 1)}}
        end
      end)

      ci = Enum.map(ci, fn el_tuple ->
        idx = elem(el_tuple, 0)
        el = elem(el_tuple, 1)
        {idx, Enum.sort_by(ci, &elem(&1, 0))}
      end)
      # end of parallel for (sort)

      scan_result = Enum.scan(offsets, fn a, b ->
        a + b
      end)

      n_keys = Enum.at(scan_result, length(scan_result) - 1)

      # TODO: split segment into subsegments if neighbors differ (change seg_out and ranks)
      Enum.map(0..n_segs, fn i ->
        seg = Enum.at(segs, i)
        start = elem(seg, 0)
        l = elem(seg, 1)
        offset = Enum.at(offsets, i)

        {ranks, ci} = split_segment(seg_out, ranks, Enum.slice(c, start, start + offset), start)
      end)

      # Reconstruct c from ci, ordering ci by the first element of the tuple

      c = Enum.sort(ci, &elem(&1, 0))

      recursion(offset * 2, rd + 1, n_keys, c, seg_out, ranks, str_size)
    end
  end
end
