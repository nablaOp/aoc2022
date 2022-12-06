defmodule TT do
  def getInput(fileName) do
    fileName |> File.read!() |> String.split("\n") |> hd()
  end

  def findMarker(fileName) do
    fileName
    |> getInput()
    |> to_charlist()
    |> Enum.reduce({[], 0, 0}, fn s, {chunk, idx, res} ->
      case chunk do
        [c1, c2, c3, c4]
        when c1 != c2 and c1 != c3 and c1 != c4 and c2 != c3 and c2 != c4 and c3 != c4 and
               res == 0 ->
          {[c2, c3, c4, s], idx + 1, idx}

        [c1, c2, c3, c4] ->
          {[c2, c3, c4, s], idx + 1, res}

        c ->
          {c ++ [s], idx + 1, res}
      end
    end)
  end

  def is_allUnique(s, length) do
    s
    |> Enum.reduce(%{}, fn i, acc ->
      if !Map.has_key?(acc, i) do
        Map.merge(acc, %{i => i})
      else
        acc
      end
    end)
    |> Map.to_list()
    |> length() == length
  end

  def findMarkerPartTwo(fileName) do
    fileName
    |> getInput()
    |> to_charlist()
    |> Enum.reduce({[], 0, 0}, fn s, {chunk, idx, res} ->
      case length(chunk) do
        14 when res == 0 ->
          newChunk = (chunk |> tl) ++ [s]

          {newChunk, idx + 1,
           if is_allUnique(newChunk, 14) do
             idx + 1
           else
             0
           end}

        14 ->
          {(chunk |> tl) ++ [s], idx + 1, res}

        _ ->
          {chunk ++ [s], idx + 1, res}
      end
    end)
  end
end
