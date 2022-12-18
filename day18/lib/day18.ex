defmodule Day18 do
  @moduledoc """
  Documentation for `Day18`.
  """

  def get_result(file \\ "input-0.txt") do
    cubes =
      file
      |> get_input()
      |> Enum.map(fn i -> get_cube(i, 1) end)

    all_sides = length(cubes) * 6

    covered =
      cubes
      |> Enum.reduce({0, cubes |> tl}, fn cur, {res, rest} ->
        new_res =
          rest
          |> Enum.reduce(res, fn r, acc ->
            acc + compare_cubes(cur, r)
          end)

        case rest == [] do
          true -> {new_res, []}
          _ -> {new_res, rest |> tl}
        end
      end)
      |> elem(0)

    all_sides - covered * 2
  end

  def get_input(file \\ "input-0.txt") do
    file
    |> File.read!()
    |> String.split("\n")
    |> Enum.map(fn i ->
      i
      |> String.split(",")
      |> Enum.map(fn n ->
        n
        |> Integer.parse()
        |> elem(0)
      end)
      |> List.to_tuple()
    end)
  end

  def compare_cubes(f, s) do
    f
    |> Map.keys()
    |> Enum.reduce(0, fn k, acc ->
      case s |> Map.has_key?(k) do
        true -> acc + 1
        _ -> acc
      end
    end)
  end

  def get_cube({x, y, z}, s) do
    %{
      {x, y, z, x + s, y, z, x + s, y + s, z, x, y + s, z} => 1,
      {x, y, z, x + s, y, z, x + s, y, z + s, x, y, z + s} => 1,
      {x, y, z, x, y + s, z, x, y + s, z + s, x, y, z + s} => 1,
      {x, y, z + s, x + s, y, z + s, x + s, y + s, z + s, x, y + s, z + s} => 1,
      {x, y + s, z, x + s, y + s, z, x + s, y + s, z + s, x, y + s, z + s} => 1,
      {x + s, y, z, x + s, y + s, z, x + s, y + s, z + s, x + s, y, z + s} => 1
    }
  end
end
