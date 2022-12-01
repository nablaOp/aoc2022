defmodule CalorieCounting do

  def getInput() do
    File.read!("input-1.txt") |> String.split("\n")
  end

  def getResult() do
    getInput() |> Enum.reduce({0, 0}, fn x, {max, current} ->
      case {x, max, current} do
        {"", max, current} when current > max -> {current, 0}
        {"", max, _} -> {max, 0}
        {x, max, current} -> {max, current + (Integer.parse(x) |> elem(0))}
      end
    end) |> elem(0)
  end

end
