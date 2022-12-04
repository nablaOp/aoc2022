defmodule CC do
  alias ElixirLS.LanguageServer.Providers.FoldingRange.Line

  def getInput(fileName) do
    fileName |> File.read!() |> String.split("\n")
  end

  def get_resultPartOne(fileName) do
    fileName |> getInput() |> Enum.filter(fn i -> is_rangesOverlap(i) end) |> Enum.count()
  end

  def get_resultPartTwo(fileName) do
    fileName |> getInput() |> Enum.filter(fn i -> is_rangesPartlyOverlap(i) end) |> Enum.count()
  end

  def is_rangesOverlap(s) do
    with ranges <- extractRanges(s) do
      case ranges do
        [[l0, r0], [l1, r1]] ->
          (l0 <= l1 and r0 >= r1) or (l1 <= l0 and r1 >= r0)
      end
    else
      _ -> 0
    end
  end

  def is_rangesPartlyOverlap(s) do
    with ranges <- extractRanges(s) do
      case ranges do
        [[l0, r0], [l1, r1]] ->
          (l0 <= l1 and r0 >= l1) or (l0 <= r1 and r0 >= r1) or
            (l1 <= l0 and r1 >= l0) or (l1 <= r0 and l1 >= r0)
      end
    else
      _ -> 0
    end
  end

  def extractRanges(s) do
    s
    |> String.split(",")
    |> Enum.map(fn r ->
      r
      |> String.split("-")
      |> Enum.map(fn n ->
        n
        |> Integer.parse()
        |> elem(0)
      end)
    end)
  end
end
