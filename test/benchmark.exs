defmodule Audiex.Benchmark do
  def wav_1s, do: Audiex.from_file("test/benchmark/1s.wav")
  def wav_4m, do: Audiex.from_file("test/benchmark/4m.wav")
  def mp3_1s, do: Audiex.from_file("test/benchmark/1s.mp3")
  def mp3_4m, do: Audiex.from_file("test/benchmark/4m.mp3")
  def flac_1s, do: Audiex.from_file("test/benchmark/1s.flac")
  def flac_4m, do: Audiex.from_file("test/benchmark/4m.flac")

  def run do
    System.cmd("ffmpeg", ["-i", "test/benchmark/4m.flac", "test/benchmark/4m.wav"])

    Benchee.run(
      %{
        "wav_1_second" => &wav_1s/0,
        "wav_4_minute" => &wav_4m/0,
        "mp3_1_second" => &mp3_1s/0,
        "mp3_4_minute" => &mp3_4m/0,
        "flac_1_second" => &flac_1s/0,
        "flac_4_minute" => &flac_4m/0
      },
      warmup: 1,
      memory_time: 2,
      reduction_time: 2
    )

    File.rm("test/benchmark/4m.wav")
  end
end

Audiex.Benchmark.run()
