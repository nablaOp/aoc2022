defmodule Day17 do
  @moduledoc """
  Documentation for `Day17`.
  """
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
      true -> {:stop, rock}
      _ -> {:ok, rock |> Enum.map(fn {x, y} -> {x, y - 1} end)}
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

  def get_rock(step) do
    case rem(step, 5) do
      0 -> [{0, 0}, {1, 0}, {2, 0}, {3, 0}]
      1 -> [{1, 0}, {0, 1}, {1, 1}, {2, 1}, {1, 2}]
      2 -> [{0, 0}, {1, 0}, {2, 0}, {2, 1}, {2, 2}]
      3 -> [{0, 0}, {0, 1}, {0, 2}, {0, 3}]
      4 -> [{0, 0}, {1, 0}, {0, 1}, {1, 1}]
    end
  end

  def get_jet(data, step) do
    data |> Enum.at(rem(step, length(data)))
  end

  def get_new_bottom(bottom, rock) do
    # IO.inspect({bottom, rock})

    bottom ++ rock

    # rock
    # |> Enum.reduce(bottom, fn {x, y}, bottom ->
    #   by = bottom |> Enum.at(x)

    #   cond do
    #     y > by -> bottom |> List.replace_at(x, y)
    #     true -> bottom
    #   end
    # end)
  end

  def get_result(steps, file \\ "input-0.txt") do
    jet_data = get_input(file)

    initial_bottom = 0..7 |> Enum.map(fn x -> {x, 0} end)
    # initial_bottom = [0, 68, 69, 76, 76, 78, 76, 75]

    rocks =
      0..steps
      |> Enum.reduce({0, []}, fn _, {rock_type, rocks} ->
        {rock_type + 1, rocks ++ [get_rock(rock_type)]}
      end)
      |> elem(1)

    0..1_000_000
    |> Enum.reduce({rocks, :spawn, initial_bottom, 0, []}, fn _,
                                                              {rocks, action, bottom, jet_step,
                                                               current_rock} ->
      # IO.inspect({rocks, action, bottom, jet_step, current_rock})

      case {rocks |> Enum.empty?(), action} do
        {true, :spawn} ->
          {rocks, action, bottom, jet_step, current_rock}

        _ ->
          case action do
            :spawn ->
              rock = rocks |> hd |> spawn_rock(bottom)
              {rocks |> tl, :jet, bottom, jet_step, rock}

            :jet ->
              jet = get_jet(jet_data, jet_step)
              rock = current_rock |> try_push(jet, bottom)
              {rocks, :fall, bottom, jet_step + 1, rock}

            :fall ->
              rock_fall = current_rock |> try_fall(bottom)

              case rock_fall do
                {:ok, rock} ->
                  {rocks, :jet, bottom, jet_step, rock}

                {:stop, rock} ->
                  {rocks, :spawn, bottom |> get_new_bottom(rock), jet_step, rock}
              end
          end

          # |> IO.inspect()
      end
    end)
    |> elem(2)
    |> Enum.map(fn {_, y} -> y end)
    |> Enum.max()
  end

  def get_input(file) do
    file
    |> File.read!()
    |> String.graphemes()
  end
end
