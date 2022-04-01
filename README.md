# Monograph - Rewrite the Problem-Based Benchmark Suite in Elixir
### Course
Bachelor's degree in Information Systems (Bacharelado em Sistemas de Informação) - [Universidade Federal de Minas Gerais](https://ufmg.br/)

### Professor 
[Fernando Magno](https://homepages.dcc.ufmg.br/~fernando/)

### Student
Jean George 😀

### Presentation
You can take a look at my presentation [here](https://www.youtube.com/watch?v=O689IV_Oj88&t) (pt-BR).

## Goal

Rewrite the [Problem-Based Benchmark Suite](https://www.cs.cmu.edu/~pbbs/benchmarks.html) in [Elixir](https://elixir-lang.org/).


## To run
First one, install and configure Elixir (and Erlang!) on your operating system following [this](https://elixir-lang.org/install.html) tutorial.

Then clone this repo
```bash
$ git clone https://github.com/jeanGeorge/elixir-pbbs-monograph.git
```
And go to the folder
```bash
$ cd elixir-pbbs-monograph
```
We create the structure with [Mix](https://hexdocs.pm/mix/Mix.html) and make use of it's [escripts](https://hexdocs.pm/mix/master/Mix.Tasks.Escript.Build.html) for command line executables. So, to get the dependencies run
```bash
$ mix geps.get
```
After that, build the project
```bash
$ mix escript.build
```
And run one of our methods
```bash
$ escript pbbs [method_name] [methods_params]
```
Both in the root folder, to run one of the methods. See examples of how to run each method below.

## Methods
Our methods follow PBBS [specifications](https://www.cs.cmu.edu/~pbbs/benchmarks.html), including [inputs](https://www.cs.cmu.edu/~pbbs/inputs.html).

### Radix Sort
Radix Sort it's our implementation for the [Integer Sort](https://www.cs.cmu.edu/~pbbs/benchmarks/integerSort.html). So, run
```bash
$ escript pbbs RadixSort p file_location
```
Where file_location is a file containing a sequence of integers in [PBBS format](https://www.cs.cmu.edu/~pbbs/benchmarks/sequenceIO.html). You can use a local file or a valid URL acessible via GET request
```bash
$ escript pbbs RadixSort p dir/to/my/file.txt
$ escript pbbs RadixSort p https://myapi.com/my/file.txt
```
or
```bash
$ escript pbbs RadixSort p [m] n
```
To sort n integer values in a range [0, m] randomly generated. m it'optional, if not provided, m = n.

For both cases, p is the number of workers.

### Sample Sort
Sample Sort it's our implementation for the [Comparison Sort](https://www.cs.cmu.edu/~pbbs/benchmarks/comparisonSort.html). So, run
```bash
$ escript pbbs SampleSort p ll file_location
```
Where file_location is a file containing a sequence of integers, floats or strings in [PBBS format](https://www.cs.cmu.edu/~pbbs/benchmarks/sequenceIO.html). You can use a local file or a valid URL acessible via GET request
```bash
$ escript pbbs SampleSort p ll dir/to/my/file.txt
$ escript pbbs SampleSort p ll https://myapi.com/my/file.txt
```
or
```bash
$ escript pbbs SampleSort p ll [m] n
```
To sort n values in a range [0, m] randomly generated. m it'optional, if not provided, m = n.

For both cases, p is the number of workers and ll it's the lower limit used by the algoritm.


## License

[MIT](LICENSE)
