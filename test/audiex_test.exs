defmodule AudiexTest do
  use ExUnit.Case

  @test_file "test/fixtures/A440_44100.wav"

  test "from_file" do
    Path.wildcard("test/fixtures/*.*")
    |> Enum.each(fn path ->
      assert {%Nx.Tensor{} = t, 44100} = Audiex.from_file(path)
      assert {2, 44100} = Nx.shape(t)
      assert {%Nx.Tensor{} = t, 22050} = Audiex.from_file(path, sr: 22050)
      assert {2, 22050} = Nx.shape(t)
      assert {%Nx.Tensor{} = t, 22050} = Audiex.from_file(path, sr: 22050, mono: true)
      assert {1, 22050} = Nx.shape(t)
    end)
  end

  test "write!" do
    tmp = "test/out.wav"
    {audio, sr} = Audiex.from_file(@test_file)
    assert :ok = Audiex.write!(tmp, audio, sr)
    assert File.exists?(tmp)
    {audio2, sr2} = Audiex.from_file(tmp)
    assert sr == sr2
    assert Nx.abs(Nx.subtract(audio, audio2)) |> Nx.mean() |> Nx.to_number() < 5.0e-5
    File.rm(tmp)
  end
end
