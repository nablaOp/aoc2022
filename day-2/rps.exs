defmodule RPS do
  def getInput(fileName) do
    fileName |> File.read! |> String.split("\n")
  end

  def firstGame(fileName) do
    fileName |> getInput |> Enum.reduce(0, fn play, acc -> acc + (play |> String.split(" ") |> getRoundResult) end)
  end

  def secondGame(fileName) do
    fileName |> getInput |> Enum.reduce(0, fn play, acc -> acc + (play |> String.split(" ") |> getRoundResultPartTwo) end)
  end

  defguard is_draw(play) when play == {"A", "X"} or play == {"B", "Y"} or play == {"C", "Z"}
  defguard is_draw_partTwo(r) when r == "Y"

  defguard is_leftWon(play) when play == {"A", "Z"} or play == {"B", "X"} or play == {"C", "Y"}
  defguard is_leftWon_partTwo(r) when r == "X"

  def getRoundResult(play) do
    case {List.first(play), List.last(play)} do
      {l, r} when is_draw({l, r}) -> 3 + cost(r)
      {l, r} when is_leftWon({l, r}) -> 0 + cost(r)
      {_, r} -> 6 + cost(r)
    end
  end

  def getRoundResultPartTwo(play) do
    case {List.first(play), List.last(play)} do
      {l, r} when is_draw_partTwo(r) -> 3 + cost(l)
      {l, r} when is_leftWon_partTwo(r) -> 0 + cost_toLoose(l)
      {l, _} -> 6 + cost_toWin(l)
    end
  end

  def cost(choose) do
    case choose do
      "X" -> 1
      "A" -> 1
      "Y" -> 2
      "B" -> 2
      "Z" -> 3
      "C" -> 3
    end
  end

  def cost_toLoose(choose) do
    case choose do
      "A" -> 3
      "B" -> 1
      "C" -> 2
    end
  end

  def cost_toWin(choose) do
    case choose do
      "A" -> 2
      "B" -> 3
      "C" -> 1
    end
  end
end
