# Audiex

Rust bindings to read/write audio data to Elixir Nx tensors

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `audiex` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:audiex, "~> 1.0.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/audiex>.

## Usage

Nothing too fancy, it just reads and writes audio. Behind the scenes most of the heavy lifting is done by Rust's [Rodio](https://github.com/RustAudio/rodio) library which uses [Symphonia](https://github.com/pdeljanov/Symphonia)

```
iex> Audiex.from_file("audio.wav")
{%Nx.Tensor<f32[2][753356] [[...], ...]>, 44100}

iex> Audiex.from_file("audio.wav", sr: 22050, mono: true) # `sr` option requires FFMPEG to be available in your PATH
{%Nx.Tensor<f32[1][753356] [[...], ...]>, 22050}
```
Reading of files supports: WAV, MP3, FLAC, and OGG.

```
iex> Audiex.write!("audio.wav", audio_tensor, 44100)
:ok
```
Writing to files supports any format you want, as long as the format you want is WAV.

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

## License


MIT License

Copyright (c) 2025 Peter Richards

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
