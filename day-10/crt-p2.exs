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

  def calc_pixel_type(cycle, pos) do
    adj = rem(cycle, 40)

    cond do
      adj >= pos and adj < pos + 3 -> "#"
      true -> "."
    end
  end

  def get_result(file) do
    res =
      file
      |> get_input_rows()
      |> Enum.map(&process_row/1)
      |> Enum.reduce(%{cycle: 1, pos: 1, result: []}, fn command, acc ->
        case command.cmd do
          :noop ->
            %{
              cycle: acc.cycle + 1,
              pos: acc.pos,
              result: acc.result ++ [calc_pixel_type(acc.cycle, acc.pos)]
            }

          :addx ->
            %{
              cycle: acc.cycle + 2,
              pos: acc.pos + command.value,
              result:
                acc.result ++
                  [calc_pixel_type(acc.cycle, acc.pos), calc_pixel_type(acc.cycle + 1, acc.pos)]
            }
        end
      end)

    res.result |> Enum.chunk_every(40) |> Enum.map(fn r -> r |> Enum.join("") |> IO.puts() end)
  end
end

CRT.get_result("input-1.txt")
