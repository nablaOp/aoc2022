defmodule RR do
  def getInput(fileName) do
    fileName |> File.read!() |> String.split("\n")
  end

  def get_number(n) do
    case n do
      n when n > 96 and n < 123 -> n - 96
      _ -> n - 38
    end
  end

  def get_result_partTwo(fileName) do
    fileName
    |> getInput()
    |> Enum.chunk_every(3)
    |> Enum.map(fn l -> count_partTwo(l) end)
    |> Enum.reduce(0, fn i, acc ->
      acc + get_number(i |> elem(1) |> Map.keys() |> List.first())
    end)
  end

  def count_partTwo(list) do
    list
    |> Enum.reduce({0, %{}}, fn l, acc ->
      case acc do
        {idx, map} when idx == 0 ->
          {idx + 1,
           l
           |> to_charlist
           |> Enum.reduce(%{}, fn c, acc2 -> Map.merge(acc2, %{c => c}) end)}

        {idx, map} ->
          {idx + 1,
           l
           |> to_charlist
           |> Enum.reduce(%{}, fn c, acc2 ->
             if Map.has_key?(map, c) do
               Map.merge(acc2, %{c => c})
             else
               acc2
             end
           end)}
      end
    end)
  end

  def get_result(fileName) do
    fileName |> getInput |> Enum.reduce(0, fn r, acc -> acc + (r |> count |> elem(2)) end)
  end

  def count(list) do
    middle = ((list |> to_charlist |> length) / 2) |> round

    list
    |> to_charlist
    |> Enum.reduce({0, %{}, 0}, fn c, acc ->
      case acc do
        {idx, map, _} when idx < middle ->
          {idx + 1, Map.merge(map, %{c => c}), 0}

        {idx, map, res} when idx >= middle ->
          if Map.has_key?(map, c) do
            {idx + 1, map, get_number(c)}
          else
            {idx + 1, map, res}
          end

        {idx, map, res} ->
          {idx + 1, map, res}
      end
    end)
  end
end
