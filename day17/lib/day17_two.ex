defmodule Day17Two do
  @moduledoc """
  Documentation for `Day17`.
  """
  use Bitwise, only_operators: true

  def spawn_rock(rock, bottom) do
    delta = (bottom |> Enum.map(fn {_, by} -> by end) |> Enum.max()) + 4
    rock |> Enum.map(fn {x, y} -> {x + 3, y + delta} end)
  end

  def try_fall(rock, bottom) do
    hit =
      rock
      |> Enum.any?(fn {x, y} ->
        bottom |> Enum.any?(fn {bx, by} -> bx == x and by == y - 1 end)
      end)

    case hit do
      true -> rock
      _ -> rock |> Enum.map(fn {x, y} -> {x, y - 1} end)
    end
  end

  def try_push(rock, jet, bottom) do
    case jet do
      ">" ->
        hit =
          rock
          |> Enum.any?(fn {x, y} ->
            bottom |> Enum.any?(fn {bx, by} -> bx == x + 1 and by == y end)
          end)

        case hit do
          true ->
            rock

          _ ->
            right = rock |> Enum.map(fn {x, _} -> x end) |> Enum.max()

            case right do
              7 -> rock
              _ -> rock |> Enum.map(fn {x, y} -> {x + 1, y} end)
            end
        end

      "<" ->
        hit =
          rock
          |> Enum.any?(fn {x, y} ->
            bottom |> Enum.any?(fn {bx, by} -> bx == x - 1 and by == y end)
          end)

        case hit do
          true ->
            rock

          _ ->
            left = rock |> Enum.map(fn {x, _} -> x end) |> Enum.min()

            case left do
              1 -> rock
              _ -> rock |> Enum.map(fn {x, y} -> {x - 1, y} end)
            end
        end
    end
  end

  def move(area, rock, rock_height, y, jet_data, jet_step) do
    rock = try_jet(area, rock, rock_height, y, jet_data, jet_step)
    {result, new_area} = try_fall(area, rock, rock_height, y)

    case result do
      :stop -> {freeze_rock(area, rock, rock_height, y), jet_step + 1}
      _ -> move(new_area, rock, rock_height, y - 1, jet_data, jet_step + 1)
    end
  end

  def freeze_rock(area, rock, rock_height, y) do
    # IO.inspect(, label: "froze")
    # IO.inspect(rock, label: "at rock", base: :binary)
    (rock_height - 1)..0
    |> Enum.reduce(area, fn i, area ->
      area
      |> List.replace_at(
        y - i,
        rock |> Enum.at(i) ||| area |> Enum.at(y - i)
      )
    end)
  end

  def try_jet(area, rock, rock_height, y, jet_data, jet_step) do
    jet = get_jet(jet_data, jet_step)

    # IO.inspect(jet, label: "jet")
    # IO.inspect(rock, label: "at rock", base: :binary)

    {result, new_rock} =
      (rock_height - 1)..0
      |> Enum.reduce({:ok, rock}, fn i, {result, rock} ->
        case result do
          :stop ->
            {:stop, rock}

          _ ->
            current_row = area |> Enum.at(y - i)

            case jet do
              ">" ->
                line = to_right(rock |> Enum.at(i))

                case hit?(line, current_row) do
                  true ->
                    {:stop, rock}

                  _ ->
                    {:ok, rock |> List.replace_at(i, line)}
                end

              "<" ->
                line = to_left(rock |> Enum.at(i))

                # IO.inspect({line, current_row}, base: :binary)

                case hit?(line, current_row) do
                  true ->
                    {:stop, rock}

                  _ ->
                    {:ok, rock |> List.replace_at(i, line)}
                end
            end
        end
      end)

    case result do
      :stop -> rock
      _ -> new_rock
    end
  end

  def try_fall(area, rock, rock_height, y) do
    # IO.inspect(y, label: "fall")
    # IO.inspect(rock, label: "at rock", base: :binary)

    (rock_height - 1)..0
    |> Enum.reduce({:ok, area}, fn i, {result, area} ->
      case result do
        :stop ->
          {result, area}

        _ ->
          current_row = area |> Enum.at(y - i - 1)

          case hit?(rock |> Enum.at(i), current_row) do
            true ->
              {:stop, area}

            _ ->
              {:ok, area}
          end
      end
    end)
  end

  def spawn(area, rock_height) do
    area = area ++ [0b0000000] ++ [0b0000000]

    case rock_height do
      1 -> area ++ [0b0000000] ++ [0b0000000]
      2 -> area ++ [0b0000000] ++ [0b0000000] ++ [0b0000000]
      3 -> area ++ [0b0000000] ++ [0b0000000] ++ [0b0000000] ++ [0b0000000]
      4 -> area ++ [0b0000000] ++ [0b0000000] ++ [0b0000000] ++ [0b0000000] ++ [0b0000000]
    end
  end

  def hit?(rock, row) do
    # IO.inspect({rock, row}, base: :binary)
    (rock &&& row) != 0
  end

  def hit_while_shift?(rock_line, row) do
    rock_line &&& row != 0
  end

  def to_right(rock_line) do
    skip = (rock_line &&& 0b0000001) == 1

    case skip do
      true ->
        rock_line

      _ ->
        rock_line >>> 1
    end
  end

  def to_left(rock_line) do
    skip = (rock_line &&& 0b1000000) == 1

    case skip do
      true ->
        rock_line

      _ ->
        rock_line <<< 1
    end
  end

  def get_rock(step) do
    case rem(step, 5) do
      0 -> [0b0011110]
      1 -> [0b0001000, 0b0011100, 0b0001000]
      2 -> [0b0011100, 0b0000100, 0b0000100]
      3 -> [0b0010000, 0b0010000, 0b0010000]
      4 -> [0b0011000, 0b0011000]
    end
  end

  def get_jet(data, step) do
    data |> Enum.at(rem(step, length(data)))
  end

  def get_result(count, file \\ "input-0.txt") do
    jet_data = get_input(file)
    area = [0b1111111]

    rocks =
      0..(count - 1)
      |> Enum.reduce({0, []}, fn _, {rock_type, rocks} ->
        {rock_type + 1, rocks ++ [get_rock(rock_type)]}
      end)
      |> elem(1)

    rocks
    |> Enum.reduce({area, 0}, fn r, {area, jet_step} ->
      # IO.inspect(area, base: :binary)
      rock_height = r |> Enum.count()

      area = area |> spawn(rock_height)
      # IO.inspect(area, base: :binary)

      {new_area, js} =
        area
        |> move(r, rock_height, (area |> Enum.count()) - 1, jet_data, jet_step)

      new_area =
        new_area
        |> Enum.filter(fn r -> r != 0 end)

      {new_area, js}
    end)

    # |> IO.inspect(base: :binary)
  end

  # def get_new_bottom(bottom, rock) do
  #   rock |> Enum
  #   bottom ++ rock
  # end

  # def get_result(steps, file \\ "input-0.txt") do
  #   jet_data = get_input(file)

  #   initial_bottom = [0..7 |> Enum.map(fn x -> 1 end)]
  #   # initial_bottom = [0, 68, 69, 76, 76, 78, 76, 75]

  #   rocks =
  #     0..steps
  #     |> Enum.reduce({0, []}, fn _, {rock_type, rocks} ->
  #       {rock_type + 1, rocks ++ [get_rock(rock_type)]}
  #     end)
  #     |> elem(1)

  #   0..1_000_000
  #   |> Enum.reduce({rocks, :spawn, initial_bottom, 0, []}, fn _,
  #                                                             {rocks, action, bottom, jet_step,
  #                                                              current_rock} ->
  #     # IO.inspect({rocks, action, bottom, jet_step, current_rock})

  #     case {rocks |> Enum.empty?(), action} do
  #       {true, :spawn} ->
  #         {rocks, action, bottom, jet_step, current_rock}

  #       _ ->
  #         case action do
  #           :spawn ->
  #             rock = rocks |> hd |> spawn_rock(bottom)
  #             {rocks |> tl, :jet, bottom, jet_step, rock}

  #           :jet ->
  #             jet = get_jet(jet_data, jet_step)
  #             rock = current_rock |> try_push(jet, bottom)
  #             {rocks, :fall, bottom, jet_step + 1, rock}

  #           :fall ->
  #             rock_fall = current_rock |> try_fall(bottom)

  #             case rock_fall do
  #               {:ok, rock} ->
  #                 {rocks, :jet, bottom, jet_step, rock}

  #               {:stop, rock} ->
  #                 {rocks, :spawn, bottom |> get_new_bottom(rock), jet_step, rock}
  #             end
  #         end

  #         # |> IO.inspect()
  #     end
  #   end)
  #   |> elem(2)
  #   |> Enum.map(fn {_, y} -> y end)
  #   |> Enum.max()
  # end

  def get_input(file) do
    file
    |> File.read!()
    |> String.graphemes()
  end
end
