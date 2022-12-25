defmodule Day23 do
  @moduledoc """
  Documentation for `Day23`.
  """

  def get_result(file \\ "input-0.txt", rounds \\ 1) do
    {map, elves} = file |> read_file() |> parse_map_elves()

    {{elves, _}, _} =
      1..rounds
      |> Enum.reduce({{elves, map}, []}, fn r, {{elves, map}, directions} ->
        directions = transform_directions(directions)
        round = perform_round(elves, map, directions)
        # save_round(round |> elem(1), r)
        {round, directions}
      end)

    {min_x, max_x, min_y, max_y, e} = calculate_result(elves) |> IO.inspect()

    (max_x - min_x) * (max_y - min_y) - e
  end

  def save_round(map, r) do
    base = read_file("input-1.txt")

    content =
      map
      |> Map.keys()
      |> Enum.reduce(base, fn {x, y}, acc ->
        case map |> Map.fetch!({x, y}) do
          :elf ->
            base
            |> List.replace_at(y - 100, base |> Enum.at(y - 100) |> List.replace_at(x - 100, "#"))

          _ ->
            base
            |> List.replace_at(y - 100, base |> Enum.at(y - 100) |> List.replace_at(x - 100, "."))
        end
      end)

    file_name = "output/output-" <> to_string(r) <> ".txt"
    File.write!(file_name, content |> Enum.join("\n"))
  end

  def calculate_result(elves) do
    elves
    |> Map.values()
    |> Enum.reduce({0, 0, 0, 0, 0}, fn {x, y}, {min_x, max_x, min_y, max_y, elves} ->
      {
        cond do
          min_x > x or min_x == 0 -> x
          true -> min_x
        end,
        cond do
          max_x < x -> x
          true -> max_x
        end,
        cond do
          min_y > y or min_y == 0 -> y
          true -> min_y
        end,
        cond do
          max_y < y -> y
          true -> max_y
        end,
        elves + 1
      }
    end)
  end

  def transform_directions(directions) do
    case length(directions) do
      0 ->
        [:north, :south, :west, :east]

      _ ->
        (directions |> tl) ++ [directions |> hd]
    end
  end

  def perform_round(elves, map, directions) do
    intentions = get_move_intentions(elves, map, directions)

    elves
    |> Map.keys()
    |> Enum.reduce({elves, map}, fn e, {new_elves, new_map} ->
      case plan_to_go?(elves |> Map.fetch!(e), map, directions) do
        :no ->
          {new_elves, new_map}

        to ->
          case intentions |> Map.fetch!(to) do
            1 ->
              {new_elves |> Map.merge(%{e => to}),
               new_map
               |> Map.merge(%{(new_elves |> Map.fetch!(e)) => :empty})
               |> Map.merge(%{to => :elf})}

            _ ->
              {new_elves, new_map}
          end
      end
    end)
  end

  def get_move_intentions(elves, map, directions) do
    elves
    |> Map.keys()
    |> Enum.reduce(%{}, fn e, acc ->
      case plan_to_go?(elves |> Map.fetch!(e), map, directions) do
        :no ->
          acc

        to ->
          cond do
            acc |> Map.has_key?(to) -> acc |> Map.merge(%{to => (acc |> Map.fetch!(to)) + 1})
            true -> acc |> Map.merge(%{to => 1})
          end
      end
    end)
  end

  def plan_to_go?(elf, map, directions) do
    {to, count} =
      directions
      |> Enum.reduce({{}, 0}, fn d, {to, count} ->
        case to do
          {} ->
            case can_go?(elf, map, d) do
              :no -> {to, count}
              new -> {new, count + 1}
            end

          _ ->
            case can_go?(elf, map, d) do
              :no -> {to, count}
              _ -> {to, count + 1}
            end
        end
      end)

    case count do
      4 -> :no
      _ -> to
    end
  end

  def can_go?({elf_x, elf_y}, map, direction) when direction == :north do
    cond do
      can_go?({elf_x, elf_y - 1}, map) and
        can_go?({elf_x + 1, elf_y - 1}, map) and
          can_go?({elf_x - 1, elf_y - 1}, map) ->
        {elf_x, elf_y - 1}

      true ->
        :no
    end
  end

  def can_go?({elf_x, elf_y}, map, direction) when direction == :south do
    cond do
      can_go?({elf_x, elf_y + 1}, map) and
        can_go?({elf_x + 1, elf_y + 1}, map) and
          can_go?({elf_x - 1, elf_y + 1}, map) ->
        {elf_x, elf_y + 1}

      true ->
        :no
    end
  end

  def can_go?({elf_x, elf_y}, map, direction) when direction == :east do
    cond do
      can_go?({elf_x + 1, elf_y}, map) and
        can_go?({elf_x + 1, elf_y - 1}, map) and
          can_go?({elf_x + 1, elf_y + 1}, map) ->
        {elf_x + 1, elf_y}

      true ->
        :no
    end
  end

  def can_go?({elf_x, elf_y}, map, direction) when direction == :west do
    cond do
      can_go?({elf_x - 1, elf_y}, map) and
        can_go?({elf_x - 1, elf_y - 1}, map) and
          can_go?({elf_x - 1, elf_y + 1}, map) ->
        {elf_x - 1, elf_y}

      true ->
        :no
    end
  end

  def can_go?(to, map) do
    !(map |> Map.has_key?(to)) or map |> Map.fetch!(to) == :empty
  end

  def parse_map_elves(data) do
    data
    |> Enum.with_index(fn element, index -> {index, element} end)
    |> Enum.reduce({%{}, %{}}, fn {y, row}, acc ->
      row
      |> Enum.with_index(fn element, index -> {index, element} end)
      |> Enum.reduce(acc, fn {x, val}, {map, elves} ->
        {map
         |> Map.merge(%{
           {x + 100, y + 100} =>
             case val do
               "#" -> :elf
               "." -> :empty
             end
         }),
         case val do
           "#" ->
             elves
             |> Map.merge(%{(x * 1_000_000 + y) => {x + 100, y + 100}})

           _ ->
             elves
         end}
      end)
    end)
  end

  def read_file(file \\ "input-0.txt") do
    file
    |> File.read!()
    |> String.split("\n")
    |> Enum.map(&String.graphemes/1)
  end
end
