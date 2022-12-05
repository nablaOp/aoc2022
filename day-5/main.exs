defmodule Main do
  def getInput(fileName) do
    fileName |> File.read!() |> String.split("\n")
  end

  def parse(fileName) do
    fileName
    |> getInput
    |> Enum.reduce({[], [], 0}, fn l, acc ->
      case {l, acc} do
        {"", {_, _, 0}} ->
          {
            elem(acc, 0)
            |> :lists.reverse()
            |> tl()
            |> :lists.reverse()
            |> Enum.zip_with(& &1)
            |> Enum.map(fn a -> a |> Enum.filter(fn i -> i != "" end) end),
            elem(acc, 1),
            1
          }

        {l, {stacks, _, 0}} ->
          {stacks ++ buildStackLevel(l), elem(acc, 1), 0}

        {l, {_, moves, 1}} ->
          {elem(acc, 0), moves ++ extractMove(l), 1}
      end
    end)
  end

  def move(fileName) do
    {stacks, moves, _} = parse(fileName)

    moves
    |> Enum.reduce(stacks, fn [count, from, to], acc ->
      Enum.to_list(1..count)
      |> Enum.reduce(acc, fn _, a ->
        a = List.replace_at(a, to - 1, [hd(Enum.at(a, from - 1))] ++ Enum.at(a, to - 1))
        a = List.replace_at(a, from - 1, tl(Enum.at(a, from - 1)))
        a
      end)
    end)
  end

  def movePartTwo(fileName) do
    {stacks, moves, _} = parse(fileName)

    moves
    |> Enum.reduce(stacks, fn [count, from, to], acc ->
      {n, ta} =
        Enum.to_list(1..count)
        |> Enum.reduce({[], acc}, fn _, a ->
          {elem(a, 0) ++ [hd(Enum.at(elem(a, 1), from - 1))],
           List.replace_at(elem(a, 1), from - 1, tl(Enum.at(elem(a, 1), from - 1)))}
        end)

      List.replace_at(ta, to - 1, n ++ Enum.at(ta, to - 1))
    end)
  end

  def get_result(fileName, part) do
    case part do
      1 -> move(fileName)
      2 -> movePartTwo(fileName)
    end
    |> Enum.map(fn i -> i |> hd end)
    |> Enum.join("")
  end

  def buildStackLevel(l) do
    [
      l
      |> to_charlist()
      |> Enum.chunk_every(4)
      |> Enum.map(fn s -> to_string(s) end)
      |> Enum.map(fn s -> s |> String.replace([" ", "[", "]"], "") end)
    ]
  end

  def extractMove(l) do
    [
      l
      |> String.split(" ")
      |> Enum.map(fn i -> Integer.parse(i) end)
      |> Enum.filter(fn i -> i != :error end)
      |> Enum.map(fn i -> i |> elem(0) end)
    ]
  end
end
