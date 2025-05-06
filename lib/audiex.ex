defmodule Audiex do
  @type sample_rate :: pos_integer()
  @type audio_channels :: Nx.Tensor.t()
  @type audiex_result :: {audio_channels, sample_rate}
  @doc """
  This function will parse audio from a given filepath.

  Similar to Python's librosa/torchaudio, it returns a tuple of `{audio, sample_rate}`

  Audio will be an Nx.Tensor struct of shape `channels x samples`.

  Formats supported: WAV, FLAC, MP3

  Formats that work but have bugs: OGG
  For some reason the number of samples returned when decoding OGG is slightly more than expected. When loading a 1s file at 44.1k, it returns 44864 samples.
  When looking at the waveform in Audiacity there is a tail added where the audio fades out for ~17ms. Whether or not that's an issue for you will depend on your use case, but I wanted to mention it here.

  Options:
  `mono`: boolean - If you want to audio summed to mono. This will change the tensor shape to 1 x samples instead of 2 x samples.
    Default: `false`
  `sr`: integer - The sample rate. This is NOT the sample rate of the file you're reading(it will detect that automatically), but rather the sample rate you want the returned audio to be in.
    So if you pass in `sr: 22050`, regardless of whether the file is 16k, 44.1k, 96k, or any other value, you'll get back audio sampled at 22,050. Pass in `nil` to get the audio in the file's current sample rate.

    Example:
      iex> Audiex.from_file("some_file.wav")
      {#Nx.Tensor<
        f32[2][352800]
        [
          [0.50230, ...],
          ...
        ]
      >, 44100}
  """
  @spec from_file(path :: String.t(), opts :: list) :: audiex_result
  def from_file(path, opts \\ []) do
    opts = Keyword.validate!(opts, mono: false, sr: nil)

    if opts[:sr] do
      with_temp_file(fn tmp ->
        System.cmd("ffmpeg", [
          "-hide_banner",
          "-loglevel",
          "error",
          "-i",
          path,
          "-af",
          "lowpass=f=#{floor(opts[:sr] / 2)},dynaudnorm",
          "-ar",
          to_string(opts[:sr]),
          tmp
        ])

        Audiex.Native.read_from_file(tmp)
      end)
    else
      Audiex.Native.read_from_file(path)
    end
    |> then(fn {channels, sr} ->
      {Enum.map(channels, &Nx.from_binary(&1, :f32)) |> Nx.stack(), sr}
    end)
    |> then(fn {audio, sr} ->
      {if(opts[:mono], do: to_mono(audio), else: audio), sr}
    end)
  end

  @doc """
  Sums a stereo signal to mono.
  """
  @spec to_mono(audio_channels) :: audio_channels
  def to_mono(channels), do: Nx.sum(channels, axes: [0], keep_axes: true)

  @doc """
  This function will parse audio that has already been read from a file.

    ## Examples

      iex> "some_file.mp3" |> File.read!() |> Audiex.from_buffer()
      {#Nx.Tensor<
        f32[2][352800]
        [
          [0.50230, ...],
          ...
        ]
      >, 44100}

  However if you have a filepath, it is preferrable to just call `from_file/1` directly.
  This function is mostly for the times where you don't have the data in a file and don't really want to write it to a file.
  """
  @spec from_buffer(path :: binary()) :: audiex_result
  def from_buffer(bin) do
    Base.encode64(bin)
    |> Audiex.Native.read_from_base64()
    |> then(fn {channels, sr} ->
      {Enum.map(channels, &Nx.from_binary(&1, :f32)) |> Nx.stack(), sr}
    end)
  end

  @doc """
  This function writes audio data to a file. It will write it in any format you want, as long as the format you want it WAV.

  Because it can be annoying when different libraries have the filepath and data is different arg positions. This function will accept any of the following:
  # This follows the convention of a module accept "it's own" data as the first arg
  write!(audio :: Nx.Tensor.t(), path :: String.t(), sr :: pos_integer())
  # This follows the `File.write!/2` format of path first
  write!(path :: String.t(), audio :: Nx.Tensor.t(), sr :: pos_integer())
  # These two are the same as above but accept the output tuple from `from_file/2`, `from_buffer/1` rather than the audio/sample rate being different args.
  write!(path :: String.t(), data :: {Nx.Tensor.t(), pos_integer()})
  write!(data :: {Nx.Tensor.t(), pos_integer()}, path :: String.t())

  Unlike `from_file/2` that can automatically handle the sample rate for you, this function cannot. Since you're passing in raw samples, you need to also pass in the sample rate.
  """
  @spec write!(path :: String.t(), data :: {Nx.Tensor.t(), sample_rate}) :: :ok
  @spec write!(data :: {Nx.Tensor.t(), sample_rate}, path :: String.t()) :: :ok
  def write!("" <> path, {%Nx.Tensor{} = tensor, sr}), do: write!(path, tensor, sr)
  def write!({%Nx.Tensor{} = tensor, sr}, "" <> path), do: write!(path, tensor, sr)

  @spec write!(path :: String.t(), audio :: Nx.Tensor.t(), sr :: sample_rate) :: :ok
  @spec write!(audio :: Nx.Tensor.t(), path :: String.t(), sr :: sample_rate) :: :ok
  def write!(%Nx.Tensor{} = t, "" <> path, sr), do: write!(path, t, sr)

  def write!("" <> path, %Nx.Tensor{} = t, sr) do
    case Nx.shape(t) do
      {_} -> Nx.new_axis(t, 0)
      {ch, _} when ch in [1, 2] -> t
    end
    |> Nx.to_batched(1)
    |> Enum.map(&(Nx.squeeze(&1, axes: [0]) |> Nx.to_binary()))
    |> then(&Audiex.Native.write_to_file(path, sr, &1))

    :ok
  end

  defp with_temp_file(fun, ext \\ ".wav") do
    int = System.unique_integer([:positive])
    path = "/tmp/audiex_#{int}#{ext}"
    result = fun.(path)
    File.rm!(path)
    result
  end
end
