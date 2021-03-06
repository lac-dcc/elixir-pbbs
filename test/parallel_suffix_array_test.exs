defmodule ParallelSuffixArrayTest do
  use ExUnit.Case

  @tag skip: true
  test "sample lorem ipsum string" do
    input = "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum."

    expected = [145,392,523,80,5,451,567,245,366,418,74,445,561,529,181,223,290,157,467,198,48,90,239,286,275,434,490,119,21,309,343,130,270,183,86,248,385,539,99,64,304,11,212,299,518,218,471,261,415,558,32,190,265,457,373,168,39,498,476,407,333,202,427,14,135,509,230,110,252,125,27,141,388,95,295,35,403,215,176,193,225,52,320,355,160,549,369,152,485,398,108,466,285,332,151,573,244,365,73,148,396,149,146,393,147,395,394,524,81,6,452,568,246,367,419,75,0,446,562,534,530,182,224,531,462,439,337,220,535,185,351,291,206,158,468,199,49,113,360,302,116,515,379,88,371,250,412,423,459,91,208,501,240,287,319,139,479,276,358,234,542,435,204,313,118,384,211,470,260,201,51,364,115,491,545,120,22,526,102,67,144,391,522,222,197,274,98,298,517,414,38,475,406,229,140,533,301,411,478,233,312,383,210,259,363,92,430,409,310,78,3,449,565,335,155,237,93,347,480,277,537,133,174,551,464,283,56,324,492,344,425,420,431,58,326,131,127,29,188,417,560,34,192,271,512,444,47,342,63,508,548,331,184,532,362,463,489,402,359,87,249,143,390,97,297,37,405,429,154,505,350,318,282,520,235,16,386,137,540,100,65,442,45,340,61,506,546,329,440,338,171,42,305,554,12,381,503,213,487,400,272,257,180,243,521,221,536,163,494,378,525,300,410,311,209,187,519,502,186,352,292,543,19,268,353,483,79,4,450,566,85,10,456,572,336,219,207,236,122,24,472,17,123,25,156,238,167,387,94,159,138,357,541,469,200,50,114,101,66,443,46,341,62,507,547,330,361,317,441,339,162,267,262,164,556,437,172,348,43,481,306,278,308,217,294,416,559,33,191,511,179,242,316,266,555,436,178,241,496,375,473,76,1,447,563,263,165,303,497,458,196,228,232,55,323,18,374,169,40,82,7,453,569,499,376,538,134,175,205,422,117,516,474,477,408,77,2,448,564,334,281,170,41,380,315,552,255,106,71,528,89,433,557,372,13,109,251,397,465,284,150,461,203,413,382,346,424,57,325,428,504,15,136,553,493,293,510,231,460,345,111,104,69,83,8,454,570,253,289,129,247,31,264,426,214,368,438,112,173,126,28,488,401,142,389,96,296,36,404,349,44,60,328,482,307,216,177,495,421,314,105,70,432,59,327,279,513,194,226,53,321,500,544,377,84,9,455,571,121,23,356,161,280,254,527,103,68,288,273,258,132,550,256,514,370,153,486,399,166,128,30,20,269,189,124,26,354,484,107,72,195,227,54,322]
    assert ParallelSuffixArray.suffix_array(input) == expected
  end

  @tag skip: true
  test "string with repeated 2-character patterns (triggers two iterations)" do
    input = "ACACACACACACACACACACACACACACACACACACACACACACACACACACACACACACAC"

    # [60, 58, ..., 2, 0, 61, 59, ..., 3, 1]
    expected = Enum.to_list(60..0//-2) ++ Enum.to_list(61..1//-2)

    assert ParallelSuffixArray.suffix_array(input) == expected
  end

  @tag skip: true
  test "trigrams input (timing only)" do
    trigrams = File.read!("tests/suffix_array/trigrams/original_trigrams_input")

    {time, res} = Benchmark.measure(fn -> NaiveParallelSuffixArray.suffix_array(trigrams, 4) end)
    IO.puts("NaiveParallelSuffixArray: #{time/1000}ms")
    {times, ress} = Benchmark.measure(fn -> SequentialSuffixArray.suffix_array(trigrams) end)

    IO.puts("SequentialSuffixArray: #{times/1000}ms")
  end

  defp to_csv(header, data, line_mapping_fn) do
    lines = Enum.map(data, fn line -> line_mapping_fn.(line) end)
    lines = [header | lines]

    Enum.join(lines, "\n")
  end

  @tag skip: true
  test "large dna input" do
    tests = 20000..300000//20000
    |> Enum.map(fn size ->
      {
        size,
        "tests/suffix_array/dna/dna_#{size}",
        "tests/suffix_array/dna/output_dna_#{size}"
      }
    end)

    data = Enum.map(tests, fn ({size, infile, outfile}) ->
      trigrams = File.read!(infile)
      out = String.trim(File.read!(outfile))
      expected = Enum.map(String.split(out, " "), &String.to_integer(&1))

      lista = Enum.map(1..30, fn _i ->
        {t2, res2} = Benchmark.measure(fn -> NaiveParallelSuffixArray.suffix_array(trigrams, 2) end)
        {t4, res4} = Benchmark.measure(fn -> NaiveParallelSuffixArray.suffix_array(trigrams, 4) end)
        {t6, res6} = Benchmark.measure(fn -> NaiveParallelSuffixArray.suffix_array(trigrams, 6) end)
        {t8, res8} = Benchmark.measure(fn -> NaiveParallelSuffixArray.suffix_array(trigrams, 8) end)
        {t12, res12} = Benchmark.measure(fn -> NaiveParallelSuffixArray.suffix_array(trigrams, 12) end)
        {t24, res24} = Benchmark.measure(fn -> NaiveParallelSuffixArray.suffix_array(trigrams, 24) end)
        {tserial, resserial} = Benchmark.measure(fn -> SequentialSuffixArray.suffix_array(trigrams) end)

        assert expected == res2
        assert expected == res24

        IO.puts("Testcase: #{infile}")
        IO.puts("T2: #{t2 / 1000}ms")
        IO.puts("T4: #{t4 / 1000}ms")
        IO.puts("T6: #{t6 / 1000}ms")
        IO.puts("T8: #{t8 / 1000}ms")
        IO.puts("T12: #{t12 / 1000}ms")
        IO.puts("T24: #{t24 / 1000}ms")
        IO.puts("Non-Parallel: #{tserial / 1000}ms")

        {infile, (t2/1000), (t4/1000), (t6/1000), (t8/1000), (t12/1000), (t24/1000), (tserial/1000)}
      end)

      t2_avg = (Enum.map(lista, fn l -> elem(l, 1) end) |> Enum.sum()) / length(lista)
      t4_avg = (Enum.map(lista, fn l -> elem(l, 2) end) |> Enum.sum()) / length(lista)
      t6_avg = (Enum.map(lista, fn l -> elem(l, 3) end) |> Enum.sum()) / length(lista)
      t8_avg = (Enum.map(lista, fn l -> elem(l, 4) end) |> Enum.sum()) / length(lista)
      t12_avg = (Enum.map(lista, fn l -> elem(l, 5) end) |> Enum.sum()) / length(lista)
      t24_avg = (Enum.map(lista, fn l -> elem(l, 6) end) |> Enum.sum()) / length(lista)
      tserial_avg = (Enum.map(lista, fn l -> elem(l, 7) end) |> Enum.sum()) / length(lista)

      {infile, t2_avg, t4_avg, t6_avg, t8_avg, t12_avg, t24_avg, tserial_avg}
    end)

    header = "test_size,t2,t4,t6,t8,t12,t24,tserial"
    csv = to_csv(header, data, fn ({size, t2, t4, t6, t8, t12, t24, tserial}) ->
      "#{size},#{t2},#{t4},#{t6},#{t8},#{t12},#{t24},#{tserial}"
    end)
    File.write!("results_dna_naive_multiple_cores.csv", csv)
  end

  @tag timeout: :infinity
  test "large trig input multiple cores" do
    tests = 20..260//20
    |> Enum.map(fn size ->
      {
        size,
        "tests/suffix_array/trigrams/input#{size}",
        "tests/suffix_array/trigrams/output#{size}"
      }
    end)

    data = Enum.map(tests, fn ({size, infile, outfile}) ->
      trigrams = File.read!(infile)
      out = String.trim(File.read!(outfile))
      expected = Enum.map(String.split(out, " "), &String.to_integer(&1))

      lista = Enum.map(1..30, fn _i ->
        {t2, res2} = Benchmark.measure(fn -> NaiveParallelSuffixArray.suffix_array(trigrams, 2) end)
        {t4, res4} = Benchmark.measure(fn -> NaiveParallelSuffixArray.suffix_array(trigrams, 4) end)
        {t6, res6} = Benchmark.measure(fn -> NaiveParallelSuffixArray.suffix_array(trigrams, 6) end)
        {t8, res8} = Benchmark.measure(fn -> NaiveParallelSuffixArray.suffix_array(trigrams, 8) end)
        {t12, res12} = Benchmark.measure(fn -> NaiveParallelSuffixArray.suffix_array(trigrams, 12) end)
        {t24, res24} = Benchmark.measure(fn -> NaiveParallelSuffixArray.suffix_array(trigrams, 24) end)
        {tserial, resserial} = Benchmark.measure(fn -> SequentialSuffixArray.suffix_array(trigrams) end)

        assert expected == res2
        assert expected == res24

        IO.puts("Testcase: #{infile}")
        IO.puts("T2: #{t2 / 1000}ms")
        IO.puts("T4: #{t4 / 1000}ms")
        IO.puts("T6: #{t6 / 1000}ms")
        IO.puts("T8: #{t8 / 1000}ms")
        IO.puts("T12: #{t12 / 1000}ms")
        IO.puts("T24: #{t24 / 1000}ms")
        IO.puts("Non-Parallel: #{tserial / 1000}ms")

        {size, (t2/1000), (t4/1000), (t6/1000), (t8/1000), (t12/1000), (t24/1000), (tserial/1000)}
      end)

      t2_avg = (Enum.map(lista, fn l -> elem(l, 1) end) |> Enum.sum()) / length(lista)
      t4_avg = (Enum.map(lista, fn l -> elem(l, 2) end) |> Enum.sum()) / length(lista)
      t6_avg = (Enum.map(lista, fn l -> elem(l, 3) end) |> Enum.sum()) / length(lista)
      t8_avg = (Enum.map(lista, fn l -> elem(l, 4) end) |> Enum.sum()) / length(lista)
      t12_avg = (Enum.map(lista, fn l -> elem(l, 5) end) |> Enum.sum()) / length(lista)
      t24_avg = (Enum.map(lista, fn l -> elem(l, 6) end) |> Enum.sum()) / length(lista)
      tserial_avg = (Enum.map(lista, fn l -> elem(l, 7) end) |> Enum.sum()) / length(lista)

      {size, t2_avg, t4_avg, t6_avg, t8_avg, t12_avg, t24_avg, tserial_avg}
    end)

    header = "test_size,t2,t4,t6,t8,t12,t24,tserial"
    csv = to_csv(header, data, fn ({size, t2, t4, t6, t8, t12, t24, tserial}) ->
      "#{size * 10000},#{t2},#{t4},#{t6},#{t8},#{t12},#{t24},#{tserial}"
    end)
    File.write!("results_trig_naive_multiple_cores.csv", csv)
  end

  @tag skip: true
  test "large trig input" do
    tests = 20..260//20
    |> Enum.map(fn size ->
      {
        size,
        "tests/suffix_array/trigrams/input#{size}",
        "tests/suffix_array/trigrams/output#{size}"
      }
    end)

    data = Enum.map(tests, fn ({size, infile, outfile}) ->
      trigrams = File.read!(infile)
      out = String.trim(File.read!(outfile))
      expected = Enum.map(String.split(out, " "), &String.to_integer(&1))

      lista = Enum.map(1..20, fn _i ->
        {t1, res} = Benchmark.measure(fn -> NaiveParallelSuffixArray.suffix_array(trigrams) end)
        {t2, res2} = Benchmark.measure(fn -> SequentialSuffixArray.suffix_array(trigrams) end)

        assert expected == res
        assert expected == res2

        IO.puts("Testcase: #{infile}")
        IO.puts("Parallel: #{t1 / 1000}ms")
        IO.puts("Non-Parallel: #{t2 / 1000}ms")

        {infile, (t1/1000), (t2/1000)}
      end)

      t1_avg = (Enum.map(lista, fn l -> elem(l, 1) end) |> Enum.sum()) / length(lista)
      t2_avg = (Enum.map(lista, fn l -> elem(l, 2) end) |> Enum.sum()) / length(lista)

      {size, t1_avg, t2_avg}
    end)

    header = "test_size,parallel_time,non_parallel_time"
    csv = to_csv(header, data, fn ({size, parallel_time, non_parallel_time}) ->
      "#{size * 10000},#{parallel_time},#{non_parallel_time}"
    end)
    File.write!("results_trigrams_naive.csv", csv)
  end

  @tag skip: true
  test "naive" do
    tests = 1..9
    |> Enum.map(fn size ->
      {"tests/suffix_array/trigrams/small/small_input#{size}",
      "tests/suffix_array/trigrams/small/small_output#{size}"}
    end)

    data = Enum.map(tests, fn ({infile, outfile}) ->
      trigrams = File.read!(infile)
      out = String.trim(File.read!(outfile))
      expected = Enum.map(String.split(out, " "), &String.to_integer(&1))

      lista = Enum.map(0..10, fn _i ->
        {t1, res} = Benchmark.measure(fn -> ParallelSuffixArray.suffix_array(trigrams) end)
        {t2, res2} = Benchmark.measure(fn -> NonParallelSuffixArray.suffix_array(trigrams) end)
        {tnaive, res3} = Benchmark.measure(fn -> SequentialSuffixArray.suffix_array(trigrams) end)

        assert expected == res
        assert expected == res2
        assert expected == res3

        IO.puts("Testcase: #{infile}")
        IO.puts("Naive: #{tnaive / 1000}ms")
        IO.puts("Parallel: #{t1 / 1000}ms")
        IO.puts("NonParallel: #{t2 / 1000}ms")

        {infile, (tnaive / 1000), (t1 / 1000), (t2 / 1000)}
      end)

      tnaive_avg = (Enum.map(lista, fn l -> elem(l, 1) end) |> Enum.sum()) / length(lista)
      t1_avg = (Enum.map(lista, fn l -> elem(l, 2) end) |> Enum.sum()) / length(lista)
      t2_avg = (Enum.map(lista, fn l -> elem(l, 3) end) |> Enum.sum()) / length(lista)

      {infile, tnaive_avg, t1_avg, t2_avg}
    end)

    header = "test_size,naive_time,parallel_time,nonparallel_time"
    csv = to_csv(header, data, fn ({infile, naive_time, t1, t2}) ->
      "#{infile},#{naive_time},#{t1},#{t2}"
    end)
    File.write!("results_with_naive.csv", csv)
  end

  @tag skip: true
  test "ab" do
    to_sort = Stream.repeatedly(fn -> :rand.uniform(10000000) end) |> Stream.uniq |> Enum.take(1000000)
    :erlang.system_flag(:schedulers_online, 8)
    {time, res} = Benchmark.measure(fn -> Sequences.SampleSort.sample_sort(10, to_sort) end)
    {time_serial, res_serial} = Benchmark.measure(fn -> Enum.sort(to_sort) end)

    assert res == res_serial

    IO.puts("SampleSort timings for reversed list with 10k elements")
    IO.puts("time: #{time / 1000}ms")
    IO.puts("time_serial: #{time_serial / 1000}ms")
  end

end
