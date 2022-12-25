defmodule Day12 do
  @moduledoc """
  Documentation for `Day12`.
  """

  def get_result(file \\ "input-0.txt") do
    map = file |> read_file() |> IO.inspect(label: "area", charlists: :as_lists)

    start_point = map |> find_start_point()
    end_point = map |> find_end_point()

    # find_possible_moves({4, 2}, map)
    # res = make_step_2(start_point, {[start_point], [start_point]}, map, end_point, [])
    # length(res)
    dijkstra(map, start_point)
  end

  def read_file(file \\ "input-0.txt") do
    file
    |> File.read!()
    |> String.split("\n")
    |> Enum.map(fn i ->
      i
      |> String.graphemes()
      |> Enum.map(fn c -> :binary.first(c) end)
    end)
  end

  def find_start_point(area) do
    find_point(area, 83)
  end

  def find_end_point(area) do
    find_point(area, 69)
  end

  def find_point(area, code) do
    area
    |> Enum.with_index(fn i, idx -> {i, idx} end)
    |> Enum.reduce_while(nil, fn {row, y}, acc ->
      if acc == nil,
        do: {
          :cont,
          row
          |> Enum.with_index(fn i, idx -> {i, idx} end)
          |> Enum.reduce_while(acc, fn {c, x}, acc ->
            if c != code, do: {:cont, acc}, else: {:halt, {x, y}}
          end)
        },
        else: {:halt, acc}
    end)
  end

  def dijkstra(map, start) do
    dist =
      map
      |> reduce(%{}, fn {x, y}, value, acc ->
        acc |> Map.merge(%{{x, y} => -1})
      end)

    prev =
      map
      |> reduce(%{}, fn {x, y}, value, acc ->
        acc |> Map.merge(%{{x, y} => nil})
      end)

    q =
      map
      |> reduce([], fn {x, y}, value, acc ->
        acc ++ [{x, y}]
      end)

    dist = dist |> Map.merge(%{start => 0})
  end

  def while(q, res) when q == [] do
    res
  end

  def while(q, dist, res) do
    {u, _} =
      q
      |> Enum.reduce({{0, 0}, 0}, fn {v, min}, acc ->
        case dist |> Map.fetch!(v) do
          val when val <= min -> {v, val}
          _ -> {v, min}
        end
      end)

    q = q |> Enum.filter(fn i -> i != u end)

    while(q, res)
  end

  def reduce(map, acc, fun) do
    map
    |> Enum.with_index(fn i, idx -> {i, idx} end)
    |> Enum.reduce(acc, fn {row, y}, acc ->
      row
      |> Enum.with_index(fn i, idx -> {i, idx} end)
      |> Enum.reduce(acc, fn {value, x}, acc ->
        fun.({x, y}, value, acc)
      end)
    end)
  end

  def make_step_2(pos, {path, visited}, map, end_point, res) do
    moves =
      pos
      |> find_possible_moves(map)
      |> Enum.filter(fn p -> visited |> Enum.all?(fn v -> v != p end) end)
      |> Enum.map(fn s -> add_step_to_path({path, visited}, s) end)
      # |> IO.inspect(label: "moves")
      |> Enum.reduce(res, fn {p, v, l}, acc ->
        case l do
          ep when ep == end_point ->
            cond do
              acc == [] or length(p) < length(acc) -> p
              true -> acc
            end

          _ ->
            make_step_2(l, {p, v}, map, end_point, acc)
            # acc ++ [{p, v, l}]
            # case make_step_2(l, {p, v}, map, end_point, acc) do
            #   r when r != [] -> acc ++ r
            #   _ -> acc
            # end
        end
      end)

    cond do
      moves == [] -> res
      true -> moves
    end
  end

  def make_step(pos, {path, visited}, map, end_point) do
    pos
    |> find_possible_moves(map)
    |> Enum.filter(fn p -> visited |> Enum.all?(fn v -> v != p end) end)
    |> Enum.reduce([], fn m, acc ->
      case m == end_point do
        true ->
          acc

        _ ->
          {p, v, l} = add_step_to_path({path, visited}, m)
          # acc = acc ++ [{p, v, l}]
          make_step(l, {p, v}, map, end_point)
      end
    end)
  end

  def add_step_to_path({path, visited}, {x, y}) do
    {path ++ [{x, y}], visited ++ [{x, y}], {x, y}}
  end

  def find_possible_moves({x, y}, map) do
    max_x = length(map |> Enum.at(0))
    max_y = length(map)

    [{0, 1}, {1, 0}, {0, -1}, {-1, 0}]
    |> Enum.reduce([], fn {tx, ty}, acc ->
      case {x + tx, y + ty} do
        {nx, ny}
        when nx >= 0 and ny >= 0 and nx < max_x and ny < max_y ->
          case can_move?({x, y}, {nx, ny}, map) do
            true -> acc ++ [{nx, ny}]
            _ -> acc
          end

        _ ->
          acc
      end
    end)
    |> Enum.sort(&(&1 |> get_val(map) > &2 |> get_val(map)))
  end

  def can_move?(from, to, map) do
    case {from |> get_val(map), to |> get_val(map)} do
      {f, t} when f == 83 and t < 99 -> true
      {f, t} when t == 69 and f > 120 -> true
      {f, t} when t != 69 and t != 83 and t <= f + 1 -> true
      _ -> false
    end
  end

  def get_val({x, y}, map) do
    map |> Enum.at(y) |> Enum.at(x)
  end
end
