defmodule Day23 do
  @moduledoc """
  Documentation for `Day23`.
  """

  def get_result(file \\ "input-0.txt") do
    {map, elves} =
      file
      |> read_file()
      |> parse_map_elves()
  end

  def move_intenions(elves, map, directions) do
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
    |> Enum.reduce({%{}, %{}}, fn {x, row}, acc ->
      row
      |> Enum.with_index(fn element, index -> {index, element} end)
      |> Enum.reduce(acc, fn {y, val}, {map, elves} ->
        {map
         |> Map.merge(%{
           {x, y} =>
             case val do
               "#" -> :elf
               "." -> :empty
             end
         }),
         case val do
           "#" ->
             elves
             |> Map.merge(%{(x * 1_000_000 + y) => {x, y}})

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
