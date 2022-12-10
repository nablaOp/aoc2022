defmodule CRT do
  def get_input_rows(file) do
    file |> File.read!() |> String.split("\n")
  end

  def process_row(r) do
    case r |> String.split(" ") do
      ["addx", value] -> %{cmd: :addx, value: value |> Integer.parse() |> elem(0)}
      ["noop"] -> %{cmd: :noop, value: 0}
    end
  end

  def multiply_signal_or_ignore(cycle, signal) do
    cond do
      rem(cycle - 20, 40) == 0 ->
        signal * cycle

      true ->
        0
    end
  end

  def add_to_res(cycles, value) do
    cycles |> Enum.map(fn c -> multiply_signal_or_ignore(c, value) end) |> Enum.sum()
  end

  def get_result(file) do
    res =
      file
      |> get_input_rows()
      |> Enum.map(&process_row/1)
      |> Enum.reduce(%{cycle: 1, signal: 1, result: [1]}, fn command, acc ->
        case command.cmd do
          :noop ->
            %{
              cycle: acc.cycle + 1,
              signal: acc.signal,
              result: acc.result ++ [acc.signal]
            }

          :addx ->
            %{
              cycle: acc.cycle + 2,
              signal: acc.signal + command.value,
              result: acc.result ++ [acc.signal, acc.signal + command.value]
            }
        end
      end)

    res.result
    |> Enum.reduce(%{cycle: 1, res: 0}, fn i, acc ->
      %{cycle: acc.cycle + 1, res: acc.res + multiply_signal_or_ignore(acc.cycle, i)}
    end)
  end
end

CRT.get_result("input-1.txt") |> IO.inspect()
