defmodule Day20 do
  @moduledoc """
  Documentation for `Day20`.
  """
  def get_result(file \\ "input-0.txt") do
    {initial, data, zero} =
      file
      |> get_input()

    values = initial |> Map.values()
    length = values |> Enum.count()

    {final_map, final_data} =
      values
      |> Enum.reduce({data, values}, fn k, {map, array} ->
        new_array = move(array, length, map |> Map.fetch!(k))

        {new_array
         |> Enum.reduce({map, 0}, fn key, {map, idx} ->
           {map |> Map.put(key, idx), idx + 1}
         end)
         |> elem(0), new_array}
      end)

    final_zero = final_map |> Map.fetch!(zero)

    f = find_number(final_data, length, final_zero, 1000)
    s = find_number(final_data, length, final_zero, 2000)
    t = find_number(final_data, length, final_zero, 3000)

    f + s + t
  end

  def find_number(data, length, start, pos) do
    pos = pos - (length - 1 - start)
    # |> IO.inspect(label: "fixed pos")
    data |> Enum.at(rem(pos, length) - 1) |> elem(1)
  end

  def move(data, length, idx) do
    # IO.inspect(data, label: "old data")
    item = data |> Enum.at(idx)
    # |> IO.inspect(label: "number")
    number = item |> elem(1)

    new_pos =
      cond do
        number > 0 ->
          to_end = length - 1 - idx
          left = number - to_end

          cond do
            left >= 0 ->
              rem = rem(left, length)
              rem

            true ->
              idx + number
          end

        number < 0 ->
          to_start = idx
          number = abs(number)
          left = to_start - number

          cond do
            left > 0 ->
              idx - number

            true ->
              rem = rem(abs(left), length)
              # |> IO.inspect(label: "rem")
              length - 1 - rem
          end

        number == 0 ->
          idx
      end

    # |> IO.inspect(label: "new pos")

    {left, right} = data |> Enum.split(idx)

    arr = left ++ (right |> tl)
    # |> IO.inspect(label: "without element")

    {left, right} = arr |> Enum.split(new_pos)
    left ++ [item] ++ right
    # |> IO.inspect(label: "new data")
  end

  def get_input(file) do
    input =
      file
      |> File.read!()
      |> String.split("\n")
      |> Enum.map(fn i -> i |> Integer.parse() |> elem(0) end)
      |> Enum.with_index()

    {input
     |> Enum.reduce(%{}, fn {val, idx}, acc -> acc |> Map.put_new(idx, {idx, val}) end),
     input
     |> Enum.reduce(%{}, fn {val, idx}, acc -> acc |> Map.put_new({idx, val}, idx) end),
     input
     |> Enum.filter(fn {val, _} -> val == 0 end)
     |> Enum.map(fn {val, idx} -> {idx, val} end)
     |> hd}
  end
end
