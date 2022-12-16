# Problem-Based Benchmark Suite in Elixir

## Goal

Rewrite the [Problem-Based Benchmark Suite](https://www.cs.cmu.edu/~pbbs/benchmarks.html) in [Elixir](https://elixir-lang.org/).

## To run

Install and configure Elixir 1.14+, Erlang 24+ on your machine.
Alternatively, you can use Docker to build an image with all the dependencies and the code, as defined in `Dockerfile`. For example (extracted from `run_benchmarks.sh`):

```bash
docker build . -t elixir-pbbs
image_id=$(docker images | awk '{print $3}' | awk 'NR==2')

container_id=$(docker run -d -it "$image_id" /bin/bash)
docker exec -it "$container_id" sh -c "mix benchmark -a histogram"
```

Benchmarks are executed with the `mix benchmark` task. To execute a benchmark:

```bash
mix benchmark -a <algorithm>
```

Currently implemented algorithms:

- `histogram` - [https://cmuparlay.github.io/pbbsbench/benchmarks/histogram.html](https://cmuparlay.github.io/pbbsbench/benchmarks/histogram.html)
- `word_count` - [https://cmuparlay.github.io/pbbsbench/benchmarks/wordCounts.html](https://cmuparlay.github.io/pbbsbench/benchmarks/wordCounts.html)
- `remove_duplicates`- no PBBS page :(
- `ray_cast` - [https://cmuparlay.github.io/pbbsbench/benchmarks/rayCast.html](https://cmuparlay.github.io/pbbsbench/benchmarks/rayCast.html)
- `convex_hull` - [https://cmuparlay.github.io/pbbsbench/benchmarks/convexHull.html](https://cmuparlay.github.io/pbbsbench/benchmarks/convexHull.html)
- `suffix_array` - [https://cmuparlay.github.io/pbbsbench/benchmarks/suffixArray.html](https://cmuparlay.github.io/pbbsbench/benchmarks/suffixArray.html)
- `integer_sort` - [https://cmuparlay.github.io/pbbsbench/benchmarks/integerSort.html](https://cmuparlay.github.io/pbbsbench/benchmarks/integerSort.html)
- `comparison_sort` - [https://cmuparlay.github.io/pbbsbench/benchmarks/comparisonSort.html](https://cmuparlay.github.io/pbbsbench/benchmarks/comparisonSort.html)


Each benchmark has a number of different, preselected inputs, to exercise different communication patterns in the parallel implementations. Each benchmark compares the parallel implementation with the sequential implementation for a given problem, given the same inputs. Each implementation-input pair executes for 60 seconds, plus 2s for warmup.

Benchmarks output a CSV file with detailed runtime information to the current directory. Currently, the benchmarks are not parameterizable, so feel free to change the code in `utils/benchmarks/drivers/*` if necessary.

## License

[MIT](LICENSE)
