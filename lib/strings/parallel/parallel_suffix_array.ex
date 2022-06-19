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

    seg_out = Enum.map(1..n, fn i ->
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

  defp split_segment(seg_out, ranks, cl, start, n) do
    l = length(seg_out)

    names = Enum.map(1..n, fn i ->
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

    seg_out = Enum.map(0..n, fn i ->
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
    c, seg_out, ranks = split_segment_top(cl, n)

    offset = nchars
    nKeys = n

    # TODO: body of loop

    ranks = recursion(offset, 0, nKeys, c, seg_out, ranks)

    Enum.map(0..length(ranks), fn i -> Enum.at(c, i))
  end

  defp recursion(offset, rd, n_keys, c, seg_out, ranks) do
    if rd > 40 do
      raise "Suffix Array: internal error, too many rounds"
    end

    segs = Enum.filter(Enum.slice(seg_out, n_keys), fn seg -> elem(seg, 1) > 1 end)
    n_segs = length(segs)
    if n_segs == 0 do
      {c, ranks}
    else
      offsets = Enum.map(segs, fn seg -> elem(seg, 1) end)

      # Step 1: cut
      ci = Enum.map(segs, fn seg ->
        start = elem(seg, 0)
        seg_len = elem(seg, 1)

        Enum.slice(c, start..(start + seg_len))
      end)

      # Step 2: 'update' first elem of tuple
      ci = Enum.map(ci, fn el ->
        o = elem(el, 1) + offset
        if o >= n do
          {0, elem(el, 1)}
        else
          {Enum.at(ranks, o), elem(el, 1)}
        end
      end)

      ci = Enum.sort_by(ci, &elem(&1, 0))
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

        split_segment(Enum.slice(c, start, start + offset), n)
      end)


      # TODO: figure out a way to reconstruct 'c' from the original orders of ci
      recursion(offset * 2, rd + 1, n_keys, c, seg_out, ranks)
    end
  end
end
