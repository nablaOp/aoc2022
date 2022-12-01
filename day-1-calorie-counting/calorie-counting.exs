defmodule CalorieCounting do
alias JasonVendored.Encode

  def getInput(fileName) do
    fileName |> File.read! |> String.split("\n")
  end

  def getResultPartOne(fileName) do
    fileName |> getInput |> then(fn x -> x ++ [""] end) |> Enum.reduce({0, 0}, fn x, {max, current} ->
      case {x, max, current} do
        {"", max, current} when current > max -> {current, 0}
        {"", max, _} -> {max, 0}
        {x, max, current} -> {max, current + (Integer.parse(x) |> elem(0))}
      end
    end) |> elem(0)
  end

  def getResultPartTwo(fileName) do
    fileName |> getInput |> then(fn x -> x ++ [""] end) |> Enum.reduce({{0, 0, 0}, 0}, fn x, {max, current} ->
      case {x, max, current} do
        {"", max, current} -> {tryAddToResult(max, current), 0}
        {x, max, current} -> {max, current + (Integer.parse(x) |> elem(0))}
      end
    end) |> elem(0) |> Tuple.to_list |> Enum.reduce(0, fn x, acc -> acc + x end)
  end

  def tryAddToResult(result, value) do
    case {result, value} do
      {{f, s, _}, value} when value > f -> {value, f, s}
      {{f, s, _}, value} when value > s -> {f, value, s}
      {{f, s, t}, value} when value > t -> {f, s, value}
      _ -> result
    end
  end

end
