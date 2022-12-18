defmodule Day18Two do
  @moduledoc """
  Documentation for `Day18`.
  """

  def get_result(file \\ "input-0.txt") do
    input = file |> get_input()

    cubes =
      input
      |> Map.keys()
      |> Enum.reduce(input, fn k, acc ->
        acc = acc |> Map.replace!(k, get_cube(acc |> Map.get(k), 1))
      end)

    all_sides = (input |> Map.keys() |> Enum.max()) * 6

    {covered, marked_cubes} =
      cubes
      |> Map.keys()
      |> Enum.reduce({0, cubes}, fn k, {res, marked_cubes} ->
        {new_res, new_marked_cubes} =
          marked_cubes
          |> (Map.keys() |> Enum.filter(fn f -> f > k end))
          |> Enum.reduce({res, marked_cubes}, fn sk, {res, marked_cubes} ->
            {f, s, r} =
              compare_cubes_and_mark(
                marked_cubes |> Map.fetch!(k),
                marked_cubes |> Map.fetch!(sk)
              )

            marked_cubes = marked_cubes |> Map.replace!(k, f)
            marked_cubes = marked_cubes |> Map.replace!(sk, s)
            {res + r, marked_cubes}
          end)

        {new_res, new_marked_cubes}
      end)

    full_covered =
      marked_cubes
      |> Map.keys()
      |> Enum.reduce(0, fn k, acc ->
        case marked_cubes |> Map.fetch!(k) |> Map.values() |> Enum.sum() == 6 do
          true -> acc + 1
          _ -> acc
        end
      end)

    all_sides - covered * 2 - full_covered * 6
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
    |> Enum.with_index(1)
    |> Enum.map(fn {k, v} -> {v, k} end)
    |> Map.new()
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

  def compare_cubes_and_mark(f, s) do
    f
    |> Map.keys()
    |> Enum.reduce({f, s, 0}, fn k, {f, s, acc} ->
      case s |> Map.has_key?(k) do
        true ->
          {
            f |> Map.replace!(k, 1),
            s |> Map.replace!(k, 1),
            acc + 1
          }

        _ ->
          {f, s, acc}
      end
    end)
  end

  def get_cube({x, y, z}, s) do
    %{
      {x, y, z, x + s, y, z, x + s, y + s, z, x, y + s, z} => 0,
      {x, y, z, x + s, y, z, x + s, y, z + s, x, y, z + s} => 0,
      {x, y, z, x, y + s, z, x, y + s, z + s, x, y, z + s} => 0,
      {x, y, z + s, x + s, y, z + s, x + s, y + s, z + s, x, y + s, z + s} => 0,
      {x, y + s, z, x + s, y + s, z, x + s, y + s, z + s, x, y + s, z + s} => 0,
      {x + s, y, z, x + s, y + s, z, x + s, y + s, z + s, x + s, y, z + s} => 0
    }
  end
end
