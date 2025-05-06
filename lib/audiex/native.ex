defmodule Audiex.Native do
  @moduledoc false
  version = Mix.Project.config()[:version]
  github_url = Mix.Project.config()[:package][:source_url]

  use RustlerPrecompiled,
    otp_app: :audiex,
    crate: "audiex_native",
    base_url: "#{github_url}/releases/download/v#{version}",
    force_build: System.get_env("AUDIEX_BUILD") in ["1", "true"],
    version: version

  def read_from_file(_path), do: :erlang.nif_error(:nif_not_loaded)
  def read_from_base64(_b64), do: :erlang.nif_error(:nif_not_loaded)
  def write_to_file(_path, _sample_rate, _audio), do: :erlang.nif_error(:nif_not_loaded)
  def play(_samples, _sr, _channels), do: :erlang.nif_error(:nif_not_loaded)
end
