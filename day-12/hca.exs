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

  def get_result(file) do
    input = file |> get_input()

    area = build_area(input)

    find_start_end(area)
  end
end
