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
end
