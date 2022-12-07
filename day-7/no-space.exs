defmodule NoSpace do
  def getInput(fileName) do
    fileName |> File.read!() |> String.split("\n")
  end

  def reducePath(path) do
    path |> String.split(".") |> :lists.reverse() |> tl |> :lists.reverse() |> Enum.join(".")
  end

  def iterate(fileName, size) do
    {left, res, _} =
      fileName
      |> getInput()
      # we have same folder names under different levels
      |> Enum.reduce({%{}, %{}, ""}, fn l, acc ->
        case l |> String.split(" ") do
          ["$", "cd", dir] when dir != ".." ->
            path = elem(acc, 2) <> "." <> dir
            {Map.merge(elem(acc, 0), %{path => 0}), elem(acc, 1), path}

          [number, _] when number != "dir" and number != "$" ->
            {Enum.map(elem(acc, 0), fn {k, v} -> {k, v + (Integer.parse(number) |> elem(0))} end)
             |> Enum.into(%{}), elem(acc, 1), elem(acc, 2)}

          ["$", "cd", ".."] ->
            last = elem(acc, 0) |> Map.keys() |> :lists.reverse() |> hd()

            if Map.get(elem(acc, 0), last) < size do
              {Map.drop(elem(acc, 0), [last]),
               Map.merge(elem(acc, 1), %{last => Map.get(elem(acc, 0), last)}),
               elem(acc, 2) |> reducePath()}
            else
              {Map.drop(elem(acc, 0), [last]), elem(acc, 1), elem(acc, 2),
               elem(acc, 2) |> reducePath()}
            end

          _ ->
            acc
        end
      end)

    res =
      res
      |> Map.merge(
        left
        |> Map.keys()
        |> Enum.reduce(%{}, fn k, acc ->
          if Map.get(left, k) < size do
            Map.merge(acc, %{k => Map.get(left, k)})
          else
            acc
          end
        end)
      )
  end

  def get_result(fileName) do
    res = fileName |> iterate(100_000)

    res
    |> Map.keys()
    |> Enum.reduce(0, fn k, acc -> acc + Map.get(res, k) end)
  end

  def get_resultPartTwo(fileName) do
    res = fileName |> iterate(100_000_000)

    still_have = 70_000_000 - (res |> Map.values() |> Enum.max())
    need = 30_000_000 - still_have

    res |> Map.values() |> Enum.filter(fn i -> i >= need end) |> Enum.min()
  end
end
