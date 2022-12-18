defmodule Day16 do
  # coef: 30 start, move - 1, release - 1
  def get_result(file \\ "input-0.txt") do
    input =
      file
      |> get_input

    build_path(input, "AA", [["AA"]])

    # path_list = build_path("AA", input, {%{"AA" => true}, ["AA"], []})
  end

  def build_path(input, current, result) do
    input
    |> Map.fetch!(current)
    |> elem(1)
    |> Enum.reduce(result, fn o, acc ->
      result
      |> Enum.reduce(acc, fn r, acc ->
        acc ++ [r ++ [o]]
      end)
    end)
  end

  # def build_path(start, input, {visited, path, result}) do
  #   options = input |> Map.fetch!(start) |> elem(1)

  #   options
  #   |> Enum.filter(fn i -> visited |> Map.has_key?(i) == false end)
  #   |> Enum.map(fn o ->
  #     updated = path ++ [o]

  #     new_result = result ++ [updated]

  #     IO.inspect("res")
  #     IO.inspect(new_result)

  #     # new_result ++
  #     build_path(
  #       o,
  #       input,
  #       {visited |> Map.merge(%{o => true}), updated, new_result}
  #     )
  #   end)
  # end

  def parse_row(r) do
    # Valve AA has flow rate=0; tunnels lead to valves DD, II, BB
    res =
      r
      |> String.replace("Valve ", "")
      |> String.replace(" has flow rate", "")
      |> String.replace(" tunnels lead to valves ", "")
      |> String.replace(" tunnel leads to valve ", "")
      |> String.replace(" ", "")
      |> String.split(";")

    left = res |> hd |> String.split("=")
    right = res |> tl |> hd |> String.split(",")

    %{(left |> hd) => {left |> tl |> hd |> Integer.parse() |> elem(0), right}}
  end

  def get_input(file) do
    file
    |> File.read!()
    |> String.split("\n")
    |> Enum.reduce(%{}, fn r, acc -> acc |> Map.merge(r |> parse_row) end)
  end
end
