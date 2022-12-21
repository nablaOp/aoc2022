defmodule Day21 do
  @moduledoc """
  Documentation for `Day21`.
  """

  def get_result(file \\ "input-0.txt") do
    file
    |> get_input()
    |> build()
    |> IO.inspect()
    |> apply_operation()
  end

  def get_input(file) do
    file
    |> File.read!()
    |> String.split("\n")
    |> Enum.reduce(%{}, fn l, acc ->
      acc |> Map.merge(parse_line(l))
    end)
  end

  def build(lines) do
    build_operations(lines |> Map.fetch!("root"), lines)
  end

  def build_operations(current, lines) do
    case current |> is_integer() do
      true ->
        current

      _ ->
        left = current |> elem(0)
        operand = current |> elem(1)
        right = current |> elem(2)

        {
          case left |> is_integer() do
            true -> left
            _ -> lines |> Map.fetch!(left) |> build_operations(lines)
          end,
          operand,
          case(right |> is_integer()) do
            true -> right
            _ -> lines |> Map.fetch!(right) |> build_operations(lines)
          end
        }
    end
  end

  def apply_operation(operation) do
    left = operation |> elem(0)
    operand = operation |> elem(1)
    right = operation |> elem(2)

    left =
      case left |> is_integer() do
        true -> left
        _ -> apply_operation(left)
      end

    right =
      case right |> is_integer() do
        true -> right
        _ -> apply_operation(right)
      end

    case operand do
      "+" -> left + right
      "-" -> left - right
      "*" -> left * right
      "/" -> left / right
    end
  end

  def parse_line(line) do
    {name, action} = line |> String.split(": ") |> List.to_tuple()

    %{
      name =>
        case action |> String.contains?("+") or line |> String.contains?("-") or
               line |> String.contains?("*") or line |> String.contains?("/") do
          true -> action |> parse_as_operation
          _ -> action |> Integer.parse() |> elem(0)
        end
    }
  end

  def parse_as_operation(input) do
    input |> String.split(" ") |> List.to_tuple()
  end
end
