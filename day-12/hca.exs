defmodule HCA do
  def get_input(file) do
    file
    |> File.read!()
    |> String.split("\n")
  end

  def build_area(input) do
    input
    |> Enum.map(fn r ->
      r |> String.split("") |> Enum.filter(fn c -> c != "" end)
    end)
  end

  def find_start_end(area) do
    area
    |> Enum.reduce({{-1, -1}, {0, 0}, {0, 0}}, fn r, acc ->
      r
      |> Enum.reduce(
        {{(acc |> elem(0) |> elem(0)) + 1, -1}, acc |> elem(1), acc |> elem(2)},
        fn c, acc ->
          i = acc |> elem(0) |> elem(0)
          j = (acc |> elem(0) |> elem(1)) + 1
          pos = {i, j}
          val = area |> Enum.at(i) |> Enum.at(j)

          case val do
            "S" -> {pos, pos, acc |> elem(2)}
            "E" -> {pos, acc |> elem(1), pos}
            _ -> {pos, acc |> elem(1), acc |> elem(2)}
          end
        end
      )
    end)
  end

  def move?(area, from) do
    {i, j} = from

    [{1, 0}, {-1, 0}, {0, 1}, {0, -1}]
    |> Enum.map(fn {di, dj} ->
      ni = i + di
      nj = j + dj

      cond do
        ni > -1 and nj > -1 and ni < length(area) and nj < length(Enum.at(area, 0)) and
            is_point_to_move?(area |> get_point(i, j), area |> get_point(ni, nj)) ->
          {ni, nj}

        true ->
          {-1, -1}
      end
    end)
  end

  def is_point_to_move?(from, to) do
    cond do
      :binary.first(from) == :binary.first(to) -> true
      :binary.first(from) + 1 == :binary.first(to) -> true
      from == "y" and to == "E" -> true
      from == "S" and (to == "a" or to == "b") -> true
      true -> false
    end
  end

  def get_point(area, i, j) do
    area |> Enum.at(i) |> Enum.at(j)
  end

  def make_step(area, {res, idx, visited}, arr) do
    arr
    |> Enum.reduce({res, idx, visited}, fn
      s, acc ->
        case acc do
          {res, idx, visited} ->
            cond do
              Enum.any?(visited, fn i -> i == s end) ->
                10_000_000

              s == "E" ->
                Enum.at(res, idx) + 1

              true ->
                moves =
                  move?(area, s)
                  |> Enum.filter(fn i -> i != {-1, -1} end)

                cond do
                  length(moves) == 0 ->
                    10_000_000

                  true ->
                    min(
                      make_step(
                        area,
                        {List.replace_at(res, idx, Enum.at(res, idx) + 1), idx, visited ++ [s]},
                        [moves |> hd]
                      ),
                      # |> elem(0)
                      # |> Enum.min(),
                      make_step(
                        area,
                        {res ++ [Enum.at(res, idx) + 1], idx + 1, visited ++ [s]},
                        moves |> tl
                      )
                      # |> elem(1)
                      # |> Enum.min()
                    )
                end
            end
        end

      n ->
        n
    end)
  end

  def get_result(file) do
    input = file |> get_input()

    area = build_area(input)

    {_, s, e} = find_start_end(area)

    make_step(
      area,
      {[0], 0, [{0, 0}]},
      move?(area, s)
      |> Enum.filter(fn i -> i != {-1, -1} end)
    )
  end
end

HCA.get_result("input-0.txt")
