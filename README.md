# Audiex

**TODO: Add description**

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `audiex` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:audiex, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/audiex>.

## Benchmark

Operating System: macOS
CPU Information: Apple M1 Pro
Number of Available Cores: 10
Available memory: 16 GB
Elixir 1.18.3
Erlang 27.3.3
JIT enabled: true

Benchmark suite executing with the following configuration:
warmup: 1 s
time: 5 s
memory time: 2 s
reduction time: 2 s
parallel: 1
inputs: none specified
Estimated total run time: 1 min

Benchmarking flac_1_second ...
Benchmarking flac_4_minute ...
Benchmarking mp3_1_second ...
Benchmarking mp3_4_minute ...
Benchmarking wav_1_second ...
Benchmarking wav_4_minute ...
Calculating statistics...
Formatting results...

Name                    ips        average  deviation         median         99th %
wav_1_second        1109.91        0.90 ms     ±2.93%        0.90 ms        1.02 ms
mp3_1_second         918.15        1.09 ms     ±3.64%        1.09 ms        1.17 ms
flac_1_second        896.63        1.12 ms     ±1.82%        1.11 ms        1.17 ms
wav_4_minute           4.72      211.91 ms     ±1.47%      211.47 ms      219.81 ms
mp3_4_minute           3.74      267.61 ms     ±1.21%      266.89 ms      277.43 ms
flac_4_minute          3.51      285.19 ms     ±1.00%      284.40 ms      292.23 ms

Comparison:
wav_1_second        1109.91
mp3_1_second         918.15 - 1.21x slower +0.188 ms
flac_1_second        896.63 - 1.24x slower +0.21 ms
wav_4_minute           4.72 - 235.20x slower +211.01 ms
mp3_4_minute           3.74 - 297.03x slower +266.71 ms
flac_4_minute          3.51 - 316.53x slower +284.29 ms

Memory usage statistics:

Name             Memory usage
wav_1_second          2.95 KB
mp3_1_second          2.95 KB - 1.00x memory usage +0 KB
flac_1_second         2.95 KB - 1.00x memory usage +0 KB
wav_4_minute          3.02 KB - 1.02x memory usage +0.0703 KB
mp3_4_minute          3.02 KB - 1.02x memory usage +0.0703 KB
flac_4_minute         3.02 KB - 1.02x memory usage +0.0703 KB

**All measurements for memory usage were the same**

Reduction count statistics:

Name          Reduction count
wav_1_second           1.76 K
mp3_1_second           1.76 K - 1.00x reduction count +0 K
flac_1_second          1.76 K - 1.00x reduction count +0 K
wav_4_minute         331.13 K - 187.61x reduction count +329.37 K
mp3_4_minute         331.13 K - 187.61x reduction count +329.37 K
flac_4_minute        331.13 K - 187.61x reduction count +329.37 K

**All measurements for reduction count were the same**
