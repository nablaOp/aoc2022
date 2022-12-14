defmodule HCA do
  def get_result(file) do
    area =
      file
      |> get_input()
      |> build_area()

    se = find_start_end(area) |> Tuple.delete_at(0)

    {se, area}
  end

  def find_path(point, res, area) do
    [{1, 0}, {0, 1}, {-1, 0}, {0, -1}]
    |> Enum.reduce({point, res}, fn {ti, tj}, {{fi, fj}, res} ->
      case is_point_to_move?({fi, fj}, {fi + ti, fj + tj}, area) do
        true ->
          first = res |> hd
          first = save_point(first, {fi + ti, fj + tj})
      end
    end)
  end

  def save_point({path, visited}, point) do
    {path ++ [point], visited ++ [point]}
  end

  # def find_path({i, j}, {ei, ej}, res, area) do
  #   [{1, 0}, {0, 1}, {-1, 0}, {0, -1}]
  #   |> Enum.reduce({{i, j}, res}, fn {ti, tj}, {{i, j}, res} ->
  #     f = get_point({i, j}, area)
  #     t = get_point({i + ti, j + tj})

  #     case is_point_to_move?(f, t) do
  #       true ->
  #     end
  #   end)
  # end

  def is_point_to_move?({fi, fj}, {ti, tj}, area) do
    max_i = length(area)
    max_j = length(area |> Enum.at(0))

    cond do
      ti < 0 or ti >= max_i or tj < 0 or tj >= max_j ->
        false

      true ->
        from = get_point({fi, fj}, area)
        to = get_point({i + ti, j + tj})

        cond do
          :binary.first(from) <= :binary.first(to) -> true
          :binary.first(from) + 1 == :binary.first(to) -> true
          (from == "y" or from == "z") and to == "E" -> true
          from == "S" and (to == "a" or to == "b") -> true
          true -> false
        end
    end
  end

  def get_point(i, j, area) do
    area |> Enum.at(i) |> Enum.at(j)
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

  def build_area(input) do
    input
    |> Enum.map(fn r ->
      r |> String.split("") |> Enum.filter(fn c -> c != "" end)
    end)
  end

  def get_input(file) do
    file
    |> File.read!()
    |> String.split("\n")
  end
end
