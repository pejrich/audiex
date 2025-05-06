defmodule Audiex.MixProject do
  use Mix.Project

  @source_url "https://github.com/pejrich/audiex"
  @version "1.0.4"

  def project do
    [
      app: :audiex,
      version: @version,
      elixir: "~> 1.18",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: package(),
      description: description(),
      name: "Audiex",
      source_url: @source_url,
      docs: &docs/0
    ]
  end

  def docs do
    [
      main: "Audiex",
      name: "audiex",
      source_ref: "v#{@version}",
      canonical: "https://hexdocs.pm/audiex",
      source_url: @source_url,
      extras: ["README.md", "CHANGELOG.md", "LICENSE"]
    ]
  end

  def description,
    do: "Rust bindings to read/write audio data to Elixir Nx tensors"

  def package do
    [
      name: "Audiex",
      licenses: ["MIT"],
      links: %{
        "GitHub" => "https://github.com/pejrich/audiex",
        "HexDocs" => "https://hexdocs.pm/audiex/Audiex.html"
      },
      source_url: @source_url,
      files: ~w(lib .formatter.exs mix.exs README* LICENSE*
                  checksum-*.exs native/audiex_native/src  native/audiex_native/Cargo.toml)
    ]
  end

  # Run "mix help compile.app" to learn about applications.

  def application do
    [
      extra_applications: extra_applications(Mix.env())
    ]
  end

  defp extra_applications(:dev),
    do: [:wx, :syntax_tools, :logger, :runtime_tools, :tools, :observer]

  defp extra_applications(_), do: [:logger]

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:rustler, ">= 0.0.0", optional: true},
      {:nx, ">= 0.0.0"},
      {:benchee, ">= 0.0.0", only: [:dev]},
      {:ex_doc, ">= 0.0.0", only: [:dev], runtime: false},
      {:rustler_precompiled, "~> 0.8.0"}
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
    ]
  end
end
