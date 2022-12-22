defmodule Day21Two do
  @moduledoc """
  Documentation for `Day21`.
  """

  def get_result(file \\ "input-0.txt") do
    operations = file |> get_input() |> build()

    # |> IO.inspect()
    1..50_000_000
    |> Enum.reduce(0, fn i, acc ->
      case apply_operation(operations, i) and acc > 0 do
        true -> acc
        _ -> i
      end
    end)
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
    build_operations(lines |> Map.fetch!("root"), "root", lines)
  end

  def build_operations(current, key, lines) do
    case {key, current |> is_integer()} do
      {"humn", _} ->
        "X"

      {_, true} ->
        current

      _ ->
        left = current |> elem(0)
        operand = current |> elem(1)
        right = current |> elem(2)

        {
          case left |> is_integer() do
            true -> left
            _ -> lines |> Map.fetch!(left) |> build_operations(left, lines)
          end,
          operand,
          case(right |> is_integer()) do
            true -> right
            _ -> lines |> Map.fetch!(right) |> build_operations(right, lines)
          end
        }
    end
  end

  def apply_operation({left, operand, right}, x) when operand == "=" do
    left_result = apply_operation(left, x)
    right_result = apply_operation(right, x)

    left_result == right_result

    # case left_result |> is_number() do
    #   true -> apply_backward_operation(right_result, left_result)
    #   _ -> apply_backward_operation(left_result, right_result)
    # end
  end

  def apply_backward_operation({left, operand, right}, number) when operand == "*" do
    case {left, right} do
      {num, "X"} ->
        number / num

      {num, operation} when num |> is_integer() ->
        apply_backward_operation(operation, number / num)

      {"X", num} ->
        number / num

      {operation, num} when num |> is_integer() ->
        apply_backward_operation(operation, number / num)
    end
  end

  def apply_backward_operation({left, operand, right}, number) when operand == "+" do
    case {left, right} do
      {num, "X"} ->
        number / num

      {num, operation} when num |> is_integer() ->
        apply_backward_operation(operation, number - num)

      {"X", num} ->
        number - num

      {operation, num} when num |> is_integer() ->
        apply_backward_operation(operation, number - num)
    end
  end

  def apply_backward_operation({left, operand, right}, number) when operand == "-" do
    case {left, right} do
      {num, "X"} ->
        num - number

      {num, operation} when num |> is_integer() ->
        apply_backward_operation(operation, num - number)

      {"X", num} ->
        number + num

      {operation, num} when num |> is_integer() ->
        apply_backward_operation(operation, number + num)
    end
  end

  def apply_backward_operation({left, operand, right}, number) when operand == "/" do
    case {left, right} do
      {num, "X"} ->
        num / number

      {num, operation} when num |> is_integer() ->
        apply_backward_operation(operation, num / number)

      {"X", num} ->
        number * num

      {operation, num} when num |> is_integer() ->
        apply_backward_operation(operation, number * num)
    end
  end

  def apply_operation({left, operand, right}, x) when operand != "=" do
    left =
      case left do
        num when num |> is_integer() -> num
        n_x when n_x == "X" -> x
        _ -> apply_operation(left, x)
      end

    right =
      case right do
        num when num |> is_integer() -> num
        n_x when n_x == "X" -> x
        _ -> apply_operation(right, x)
      end

    case left |> is_integer() and right |> is_integer() do
      true ->
        case operand do
          "+" -> left + right
          "-" -> left - right
          "*" -> left * right
          "/" -> left / right
        end

      _ ->
        {left, operand, right}
    end
  end

  def apply_operation(x) when x == "X", do: x

  def parse_line(line) do
    {name, action} = line |> String.split(": ") |> List.to_tuple()

    %{
      name =>
        case action |> String.contains?("+") or line |> String.contains?("-") or
               line |> String.contains?("*") or line |> String.contains?("/") do
          true ->
            case name do
              "root" ->
                action
                |> String.replace("+", "=")
                |> String.replace("-", "=")
                |> String.replace("*", "=")
                |> String.replace("/", "=")
                |> parse_as_operation

              _ ->
                action |> parse_as_operation()
            end

          _ ->
            case name do
              "humn" ->
                "X"

              _ ->
                action |> Integer.parse() |> elem(0)
            end
        end
    }
  end

  def parse_as_operation(input) do
    input |> String.split(" ") |> List.to_tuple()
  end
end
