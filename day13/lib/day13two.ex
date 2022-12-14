defmodule Day13Two do
  def get_result(file) do
    input =
      file
      |> parse_input()

    input = input ++ [[[2]]]
    input = input ++ [[[6]]]

    sorted =
      input
      |> Enum.sort(fn i, j -> check(i, j) end)
      |> IO.inspect()

    Enum.reduce(sorted, {1, 1}, fn i, {idx, res} ->
      case i do
        [[2]] -> {idx + 1, res * idx}
        [[6]] -> {idx + 1, res * idx}
        _ -> {idx + 1, res}
      end
    end)
  end

  def parse_input(file) do
    res =
      file
      |> File.read!()
      |> String.split("\n")
      |> Enum.reduce([], fn i, acc ->
        case i do
          "" -> acc
          _ -> acc ++ [i]
        end
      end)
      |> Enum.map(fn i -> i |> parse_to_array end)

    res
  end

  def parse_to_array(s) do
    s
    |> String.graphemes()
    |> Enum.reduce({[[]], ""}, fn s, {acc, num} ->
      case s do
        "[" ->
          {acc ++ [[]], ""}

        "]" ->
          cond do
            num != "" ->
              last_with_num = (acc |> Enum.reverse() |> hd) ++ [num |> Integer.parse() |> elem(0)]
              idx = length(acc) - 1
              t = List.replace_at(acc, idx, last_with_num)
              last = t |> Enum.reverse() |> hd
              with_no_last = t |> Enum.reverse() |> tl |> Enum.reverse()
              new_last = (with_no_last |> Enum.reverse() |> hd) ++ [last]
              idx = length(with_no_last) - 1
              {List.replace_at(with_no_last, idx, new_last), ""}

            true ->
              last = acc |> Enum.reverse() |> hd
              with_no_last = acc |> Enum.reverse() |> tl |> Enum.reverse()
              new_last = (with_no_last |> Enum.reverse() |> hd) ++ [last]
              idx = length(with_no_last) - 1
              {List.replace_at(with_no_last, idx, new_last), ""}
          end

        "," when num != "" ->
          last = (acc |> Enum.reverse() |> hd) ++ [num |> Integer.parse() |> elem(0)]
          idx = length(acc) - 1
          {List.replace_at(acc, idx, last), ""}

        "," ->
          {acc, ""}

        n when n != "," ->
          {acc, num <> n}
      end
    end)
    |> elem(0)
    |> hd
    |> hd
  end

  def check(l, r) when is_integer(l) and is_integer(r), do: check_integers(l, r)
  def check(l, r) when is_list(l) and is_list(r), do: check_arrays(l, r)
  def check(l, r) when is_list(l) and is_integer(r), do: check_arrays(l, [r])
  def check(l, r) when is_integer(l) and is_list(r), do: check_arrays([l], r)

  def check_integers(l, r) do
    cond do
      l < r -> true
      l > r -> false
      l == r -> :continue
    end
  end

  def check_arrays(l, r) do
    l_len = length(l)
    r_len = length(r)

    case {l_len, r_len} do
      {0, 0} ->
        :continue

      {0, _} ->
        true

      _ ->
        0..(l_len - 1)
        |> Enum.reduce_while(:continue, fn idx, acc ->
          if acc == :continue,
            do:
              {:cont,
               cond do
                 r_len == idx ->
                   false

                 true ->
                   res = check(l |> Enum.at(idx), r |> Enum.at(idx))

                   case res do
                     :continue ->
                       cond do
                         l_len == idx + 1 and r_len > idx + 1 -> true
                         true -> :continue
                       end

                     r ->
                       r
                   end
               end},
            else: {:halt, acc}
        end)
    end
  end
end
