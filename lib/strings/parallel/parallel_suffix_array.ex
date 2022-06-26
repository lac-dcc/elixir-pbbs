# Description: https://www.cs.cmu.edu/~pbbs/benchmarks/suffixArray.html

defmodule ParallelSuffixArray do
  defp split_segment_top(cl, n) do
    mask = Bitwise.<<<(1, 32) - 1

    names = Enum.map(1..(n-1), fn i ->
      if Bitwise.>>>(Enum.at(cl, i, 0), 32) != Bitwise.>>>(Enum.at(cl, i - 1, 0), 32) do
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

  defp split_segment(seg_out, cl, start) do
    l = length(seg_out)

    names = Enum.map(1..(l-1), fn i ->
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

    indexes = 0..(l-1)
    |> Enum.map(fn i -> Enum.at(cl, i) end)
    |> Enum.map(fn el -> {elem(el, 1), elem(el, 0)} end)

    delta_ranks = Enum.map(indexes, fn ({k, v}) ->
      {k, (Enum.at(names, v, 0) + start + 1)}
    end)

    seg_out = Enum.map(0..(l-2), fn i ->
      if Enum.at(names, i+1) == i+1 do
        v = Enum.at(names, i)
        {start + v, (i+1) - v}
      else
        {0, 0}
      end
    end)
    last = {start + Enum.at(names, l-1), l - Enum.at(names, l-1)}
    seg_out = seg_out ++ [last]

    {seg_out, delta_ranks}
  end

  def suffix_array(ss) do
    ss = ss <> "\b" # Assuming that "\b" is smaller than any other character
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

    {c, _ranks} = recursion(offset, 0, nKeys, c, seg_out, ranks, n)
    ranks = Enum.map(c, &elem(&1, 1))

    tl(ranks) # drop the first element that maps to the "\b" character
  end

  defp rebuild_c(original_c, ci, idx, result) do
    if idx >= length(original_c) do
      result
    else
      matches = Enum.find(ci, fn el_tuple ->
        elem(el_tuple, 0) == idx
      end)
      if matches != nil do
        elements = elem(matches, 1)

        rebuild_c(original_c, ci, idx + length(elements), result ++ elements)
      else
        rebuild_c(original_c, ci, idx + 1, result ++ [Enum.at(original_c, idx)])
      end
    end
  end

  defp rebuild_seg_out(original_seg_out, updated_data, idx, result) do
    if idx >= length(original_seg_out) do
      result
    else
      if length(updated_data) == 0 do
        result ++ Enum.slice(original_seg_out, idx..(length(original_seg_out) - 1))
      else
        matches = Enum.find(updated_data, fn el_tuple ->
          offset_descriptor = elem(el_tuple, 1)
          offset_start = elem(offset_descriptor, 0)
          offset_start == idx
        end)
        if matches != nil do
          elements = elem(matches, 0)
          rebuild_seg_out(original_seg_out, updated_data, idx + length(elements), result ++ elements)
        else
          rebuild_seg_out(original_seg_out, updated_data, idx + 1, result ++ [Enum.at(original_seg_out, idx)])
        end
      end
    end
  end

  defp rebuild_ranks(ranks, delta_ranks, idx) do
    if length(delta_ranks) == 0 do
      ranks
    else
      current_new_rank = hd(delta_ranks)
      pos = elem(current_new_rank, 0)
      new_rank_value = elem(current_new_rank, 1)

      updated = List.update_at(ranks, pos, fn _old -> new_rank_value end)

      rebuild_ranks(updated, tl(delta_ranks), idx + 1)
    end
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
      segs = Enum.slice(seg_out, 0..(n_keys - 1))
      |> Enum.filter(fn seg ->
        elem(seg, 1) > 1
      end)

      offsets = Enum.map(segs, fn seg -> elem(seg, 1) end)
      ci = Enum.map(segs, fn seg ->
          start = elem(seg, 0)
          seg_len = elem(seg, 1)

          {start, Enum.slice(c, start, seg_len)}
      end)

      # Step 2: 'update' first elem of tuple
      ci = Enum.map(ci, fn el_tuple ->
        idx = elem(el_tuple, 0)
        current_slice = elem(el_tuple, 1)
        new_slice = Enum.map(current_slice, fn pair ->
          o = elem(pair, 1) + offset
          if o >= str_size do
            {0, elem(pair, 1)}
          else
            {Enum.at(ranks, o), elem(pair, 1)}
          end
        end)
        {idx, new_slice}
      end)

      ci = Enum.map(ci, fn element ->
        idx = elem(element, 0)
        el = elem(element, 1)
        {idx, Enum.sort_by(el, &elem(&1, 0))}
      end)

      # Reconstruct c from ci. Check if the first element of any element of ci
      # matches the index i. If that is the case, then we "flat-map" the elements
      # from that position of ci, otherwise we take c[i].
      c = rebuild_c(c, ci, 0, [])


      offsets_scan = Enum.scan([0 | offsets], &Kernel.+/2)
      offsets = elem(List.pop_at(offsets_scan, -1), 1)

      n_keys = List.last(offsets_scan)

      updated_data = Enum.map(0..(n_segs-1), fn i ->
        seg = Enum.at(segs, i)
        start = elem(seg, 0)
        l = elem(seg, 1)
        offset = Enum.at(offsets, i)

        {sg, delta_ranks} = split_segment(
          Enum.slice(seg_out, offset, l),
          Enum.slice(c, start, l),
          start
        )

        {
          sg, # updated segments
          {offset, offset + l}, # offset of updated segments within original segments
          delta_ranks # updated ranks (with position information)
        }
      end)

      seg_out = rebuild_seg_out(seg_out, updated_data, 0, [])

      delta_ranks = Enum.flat_map(updated_data, fn data -> elem(data, 2) end)

      ranks = rebuild_ranks(ranks, delta_ranks, 0)

      recursion(offset * 2, rd + 1, n_keys, c, seg_out, ranks, str_size)
    end
  end
end
