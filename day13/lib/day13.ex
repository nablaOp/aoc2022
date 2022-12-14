defmodule Day13 do
  def get_result(file) do
    file
    |> parse_input()
    |> Enum.map(fn {l, r} -> check(l, r) end)
    |> IO.inspect()
    |> Enum.reduce({1, 0}, fn i, {idx, res} ->
      case i do
        true -> {idx + 1, res + idx}
        false -> {idx + 1, res}
      end
    end)
    |> elem(1)
  end

  def parse_input(file) do
    res =
      file
      |> File.read!()
      |> String.split("\n")
      |> Enum.reduce({[], "", 0}, fn i, acc ->
        case {i, elem(acc, 2)} do
          {"", _} -> {elem(acc, 0), {}, 0}
          {s, 0} -> {elem(acc, 0), s, 1}
          {s, 1} -> {elem(acc, 0) ++ [{elem(acc, 1), s}], "", 2}
        end
      end)
      |> elem(0)
      |> Enum.map(fn {l, r} -> {l |> parse_to_array, r |> parse_to_array} end)

    res
    # |> Enum.each(fn {x, y} ->
    #   File.open!("output.txt", [:write], fn file ->
    #     IO.inspect(file, x, charlists: :as_lists, limit: :infinity)
    #     IO.inspect(file, y, charlists: :as_lists, limit: :infinity)
    #     IO.inspect(file, "", pretty: true)
    #   end)
    # end)
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
