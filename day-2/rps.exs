defmodule RPS do
  def getInput(fileName) do
    fileName |> File.read! |> String.split("\n")
  end

  def firstGame(fileName) do
    fileName |> getInput |> Enum.reduce(0, fn play, acc -> acc + (play |> String.split(" ") |> getRoundResult) end)
  end

  defguard is_draw(play) when play == {"A", "X"} or play == {"B", "Y"} or play == {"C", "Z"}

  defguard is_leftWon(play) when play == {"A", "Z"} or play == {"B", "X"} or play == {"C", "Y"}

  def getRoundResult(play) do
    case {List.first(play), List.last(play)} do
      {l, r} when is_draw({l, r}) -> 3 + rightCost(r)
      {l, r} when is_leftWon({l, r}) -> 0 + rightCost(r)
      {_, r} -> 6 + rightCost(r)
    end
  end

  def rightCost(right) do
    case right do
      "X" -> 1
      "Y" -> 2
      "Z" -> 3
    end
  end
end
