defmodule ParallelSuffixArrayTest do
  use ExUnit.Case

  test "sample lorem ipsum string" do
    input = "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum."

    expected = [145,392,523,80,5,451,567,245,366,418,74,445,561,529,181,223,290,157,467,198,48,90,239,286,275,434,490,119,21,309,343,130,270,183,86,248,385,539,99,64,304,11,212,299,518,218,471,261,415,558,32,190,265,457,373,168,39,498,476,407,333,202,427,14,135,509,230,110,252,125,27,141,388,95,295,35,403,215,176,193,225,52,320,355,160,549,369,152,485,398,108,466,285,332,151,573,244,365,73,148,396,149,146,393,147,395,394,524,81,6,452,568,246,367,419,75,0,446,562,534,530,182,224,531,462,439,337,220,535,185,351,291,206,158,468,199,49,113,360,302,116,515,379,88,371,250,412,423,459,91,208,501,240,287,319,139,479,276,358,234,542,435,204,313,118,384,211,470,260,201,51,364,115,491,545,120,22,526,102,67,144,391,522,222,197,274,98,298,517,414,38,475,406,229,140,533,301,411,478,233,312,383,210,259,363,92,430,409,310,78,3,449,565,335,155,237,93,347,480,277,537,133,174,551,464,283,56,324,492,344,425,420,431,58,326,131,127,29,188,417,560,34,192,271,512,444,47,342,63,508,548,331,184,532,362,463,489,402,359,87,249,143,390,97,297,37,405,429,154,505,350,318,282,520,235,16,386,137,540,100,65,442,45,340,61,506,546,329,440,338,171,42,305,554,12,381,503,213,487,400,272,257,180,243,521,221,536,163,494,378,525,300,410,311,209,187,519,502,186,352,292,543,19,268,353,483,79,4,450,566,85,10,456,572,336,219,207,236,122,24,472,17,123,25,156,238,167,387,94,159,138,357,541,469,200,50,114,101,66,443,46,341,62,507,547,330,361,317,441,339,162,267,262,164,556,437,172,348,43,481,306,278,308,217,294,416,559,33,191,511,179,242,316,266,555,436,178,241,496,375,473,76,1,447,563,263,165,303,497,458,196,228,232,55,323,18,374,169,40,82,7,453,569,499,376,538,134,175,205,422,117,516,474,477,408,77,2,448,564,334,281,170,41,380,315,552,255,106,71,528,89,433,557,372,13,109,251,397,465,284,150,461,203,413,382,346,424,57,325,428,504,15,136,553,493,293,510,231,460,345,111,104,69,83,8,454,570,253,289,129,247,31,264,426,214,368,438,112,173,126,28,488,401,142,389,96,296,36,404,349,44,60,328,482,307,216,177,495,421,314,105,70,432,59,327,279,513,194,226,53,321,500,544,377,84,9,455,571,121,23,356,161,280,254,527,103,68,288,273,258,132,550,256,514,370,153,486,399,166,128,30,20,269,189,124,26,354,484,107,72,195,227,54,322]
    assert ParallelSuffixArray.suffix_array(input) == expected
  end

  test "string with repeated 2-character patterns (triggers two iterations)" do
    input = "ACACACACACACACACACACACACACACACACACACACACACACACACACACACACACACAC"

    # [60, 58, ..., 2, 0, 61, 59, ..., 3, 1]
    expected = Enum.to_list(60..0//-2) ++ Enum.to_list(61..1//-2)

    assert ParallelSuffixArray.suffix_array(input) == expected
  end

  test "trigrams input" do
    trigrams = File.read!("tests/suffix_array/trigrams/trigrams.in")

    res = ParallelSuffixArray.suffix_array(trigrams)

    out = String.trim(File.read!("tests/suffix_array/trigrams/trigrams.out"))
    expected = Enum.map(String.split(out, " "), &String.to_integer(&1))

    assert expected == res
  end

  @tag timeout: 180000
  test "large trigrams input" do
    trigrams = File.read!("tests/suffix_array/trigrams/trigram_large.in")

    res = ParallelSuffixArray.suffix_array(trigrams)

    out = String.trim(File.read!("tests/suffix_array/trigrams/trigram_large.out"))
    expected = Enum.map(String.split(out, " "), &String.to_integer(&1))

    assert expected == res
  end

end
