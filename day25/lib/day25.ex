defmodule Day25 do
  @moduledoc """
  Documentation for `Day25`.
  """

  def get_result(file \\ "input-0.txt") do
    file
    |> read_file()
    |> Enum.map(fn i -> i |> to_10 end)
    |> Enum.sum()
    |> from_10_to_5()
  end

  def read_file(file \\ "input-0.txt") do
    file
    |> File.read!()
    |> String.split("\n")
  end

  def from_10_to_5(ten) do
    ten
    |> to_5_by_digits(false)
    |> Enum.map(fn i -> i |> hd end)
    |> Enum.join()
  end

  def to_5_by_digits(ten, adj) do
    div = div(ten, 5)

    rem =
      rem(ten, 5)
      |> parse_10_rem()

    rem =
      cond do
        adj -> adj_digit(rem)
        true -> rem
      end

    {adj, rem} = parse_digit_to_adj(rem)

    cond do
      div > 0 ->
        to_5_by_digits(div, adj) ++ [rem]

      true ->
        cond do
          adj -> [["1"]] ++ [rem]
          true -> [rem]
        end
    end
  end

  def parse_digit_to_adj(digit) do
    case digit do
      ["1", d] -> {true, [d]}
      _ -> {false, digit}
    end
  end

  def adj_digit(digit) do
    case digit do
      ["0"] -> ["1"]
      ["1"] -> ["2"]
      ["2"] -> ["1", "="]
      ["1", "="] -> ["1", "-"]
      ["1", "-"] -> ["1", "0"]
    end
  end

  def parse_10_rem(ten) do
    case ten do
      0 -> ["0"]
      1 -> ["1"]
      2 -> ["2"]
      3 -> ["1", "="]
      4 -> ["1", "-"]
    end
  end

  def to_10(five) do
    five
    |> String.graphemes()
    |> Enum.reverse()
    |> Enum.with_index(fn element, index -> {element, index} end)
    |> Enum.reduce(0, fn {digit, index}, acc ->
      acc + (digit |> parse_5_scale() |> apply_5_scale(index))
    end)
  end

  def parse_5_scale(digit) do
    case digit do
      "-" -> -1
      "=" -> -2
      d -> d |> Integer.parse() |> elem(0)
    end
  end

  def apply_5_scale(scale, pos) do
    scale * Integer.pow(5, pos)
  end
end
