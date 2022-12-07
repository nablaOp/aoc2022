defmodule NoSpace do
  def getInput(fileName) do
    fileName |> File.read!() |> String.split("\n")
  end

  def iterate(fileName) do
    {left, res} =
      fileName
      |> getInput()
      # we have same folder names under different levels
      |> Enum.reduce({%{}, %{}}, fn l, acc ->
        case l |> String.split(" ") do
          ["$", "cd", dir] when dir != ".." ->
            IO.inspect(Map.merge(elem(acc, 0), %{dir => 0}))
            {Map.merge(elem(acc, 0), %{dir => 0}), elem(acc, 1)}

          [number, _] when number != "dir" and number != "$" ->
            {Enum.map(elem(acc, 0), fn {k, v} -> {k, v + (Integer.parse(number) |> elem(0))} end)
             |> Enum.into(%{}), elem(acc, 1)}

          ["$", "cd", ".."] ->
            last = elem(acc, 0) |> Map.keys() |> :lists.reverse() |> hd()

            if Map.get(elem(acc, 0), last) < 100_000 do
              {Map.drop(elem(acc, 0), [last]),
               Map.merge(elem(acc, 1), %{last => Map.get(elem(acc, 0), last)})}
            else
              {Map.drop(elem(acc, 0), [last]), elem(acc, 1)}
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
          if Map.get(left, k) < 100_000 do
            Map.merge(acc, %{k => Map.get(left, k)})
          else
            acc
          end
        end)
      )

    res
    |> Map.keys()
    |> Enum.reduce(0, fn k, acc -> acc + Map.get(res, k) end)
  end
end
