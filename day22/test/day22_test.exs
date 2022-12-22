defmodule Day22Test do
  use ExUnit.Case
  doctest Day22

  test "one right step to the good place" do
    {map, path} = "input-0.txt" |> Day22.read_file()

    assert Day22.perform_step(%{:x => 8, :y => 0}, map, :right) == {:ok, %{:x => 9, :y => 0}}
  end

  test "one right step to the wall" do
    {map, path} = "input-0.txt" |> Day22.read_file()

    assert Day22.perform_step(%{:x => 10, :y => 0}, map, :right) == {:wall, %{:x => 10, :y => 0}}
  end

  test "one right step back to the start" do
    {map, path} = "input-0.txt" |> Day22.read_file()

    assert Day22.perform_step(%{:x => 11, :y => 1}, map, :right) == {:ok, %{:x => 8, :y => 1}}
  end

  test "one left step to the good place" do
    {map, path} = "input-0.txt" |> Day22.read_file()

    assert Day22.perform_step(%{:x => 9, :y => 0}, map, :left) == {:ok, %{:x => 8, :y => 0}}
  end

  test "one left step to the wall" do
    {map, path} = "input-0.txt" |> Day22.read_file()

    assert Day22.perform_step(%{:x => 10, :y => 1}, map, :left) == {:wall, %{:x => 10, :y => 1}}
  end

  test "one left step back to the end" do
    {map, path} = "input-0.txt" |> Day22.read_file()

    assert Day22.perform_step(%{:x => 8, :y => 1}, map, :left) == {:ok, %{:x => 11, :y => 1}}
  end

  test "one down step to the good place" do
    {map, path} = "input-0.txt" |> Day22.read_file()

    assert Day22.perform_step(%{:x => 8, :y => 0}, map, :down) == {:ok, %{:x => 8, :y => 1}}
  end

  test "5 down steps" do
    {map, path} = "input-0.txt" |> Day22.read_file()

    assert Day22.perform_steps(%{:x => 10, :y => 0}, map, :down, 5) == %{:x => 10, :y => 5}
  end

  test "one down step to the good place 2" do
    {map, path} = "input-0.txt" |> Day22.read_file()

    assert Day22.perform_step(%{:x => 10, :y => 0}, map, :down) == {:ok, %{:x => 10, :y => 1}}
  end

  test "one down step to the wall" do
    {map, path} = "input-0.txt" |> Day22.read_file()

    assert Day22.perform_step(%{:x => 9, :y => 0}, map, :down) == {:wall, %{:x => 9, :y => 0}}
  end

  test "one down step to the start" do
    {map, path} = "input-0.txt" |> Day22.read_file()

    assert Day22.perform_step(%{:x => 0, :y => 7}, map, :down) == {:ok, %{:x => 0, :y => 4}}
  end

  test "one up step to the good place" do
    {map, path} = "input-0.txt" |> Day22.read_file()

    assert Day22.perform_step(%{:x => 8, :y => 1}, map, :up) == {:ok, %{:x => 8, :y => 0}}
  end

  test "one up step to the wall" do
    {map, path} = "input-0.txt" |> Day22.read_file()

    assert Day22.perform_step(%{:x => 11, :y => 1}, map, :up) == {:wall, %{:x => 11, :y => 1}}
  end

  test "one up step to the end" do
    {map, path} = "input-0.txt" |> Day22.read_file()

    assert Day22.perform_step(%{:x => 8, :y => 0}, map, :up) == {:ok, %{:x => 8, :y => 11}}
  end

  test "big data. edge cases" do
    {map, path} = "input-1.txt" |> Day22.read_file()

    assert Day22.perform_step(%{:x => 50, :y => 0}, map, :up) == {:wall, %{:x => 50, :y => 0}}
    assert Day22.perform_step(%{:x => 51, :y => 0}, map, :up) == {:ok, %{:x => 51, :y => 149}}
    assert Day22.perform_step(%{:x => 50, :y => 0}, map, :left) == {:ok, %{:x => 149, :y => 0}}
    assert Day22.perform_step(%{:x => 0, :y => 199}, map, :down) == {:ok, %{:x => 0, :y => 100}}
    assert Day22.perform_step(%{:x => 99, :y => 50}, map, :right) == {:ok, %{:x => 50, :y => 50}}
    assert Day22.perform_step(%{:x => 50, :y => 50}, map, :left) == {:ok, %{:x => 99, :y => 50}}

    assert Day22.perform_step(%{:x => 88, :y => 35}, map, :right) ==
             {:wall, %{:x => 88, :y => 35}}

    assert Day22.perform_step(%{:x => 88, :y => 35}, map, :down) == {:wall, %{:x => 88, :y => 35}}
    assert Day22.perform_step(%{:x => 88, :y => 35}, map, :left) == {:ok, %{:x => 87, :y => 35}}
    assert Day22.perform_step(%{:x => 88, :y => 35}, map, :up) == {:ok, %{:x => 88, :y => 34}}
    assert Day22.perform_step(%{:x => 49, :y => 199}, map, :down) == {:ok, %{:x => 49, :y => 100}}
  end

  test "errors" do
    {map, path} = "input-1.txt" |> Day22.read_file()

    {res, mm} = Day22.perform_steps(%{:x => 15, :y => 116}, map, :up, 17, map)
    assert res == %{:x => 15, :y => 199}

    file_name = "output/output-0-test.txt"
    File.write!(file_name, mm |> Enum.join("\n"))
  end
end
