defmodule Day22 do
  @moduledoc """
  Documentation for `Day22`.
  """

  def perform_steps(pos, map, facing, count, mm) do
    # IO.inspect({pos, facing, count}, label: "perfom specfic steps")

    mm = mm |> update_map(pos, facing)

    case {count - 1, perform_step(pos, map, facing)} do
      {0, {_, new_pos}} -> {new_pos, mm}
      {cnt, {:ok, new_pos}} -> perform_steps(new_pos, map, facing, cnt, mm)
      {_, {:wall, new_pos}} -> {new_pos, mm}
    end
  end

  def perform_step(pos, map, facing) when facing == :right do
    row = map |> Enum.at(pos.y)

    next_x =
      case pos.x + 1 do
        x when x == length(row) -> row |> Enum.find_index(&(&1 in [".", "#"]))
        x -> x
      end

    case row |> Enum.at(next_x) do
      "#" -> {:wall, pos}
      _ -> {:ok, %{:x => next_x, :y => pos.y}}
    end
  end

  def perform_step(pos, map, facing) when facing == :left do
    row = map |> Enum.at(pos.y)

    next_x =
      case pos.x - 1 do
        x when x < 0 ->
          length(row) - (row |> Enum.reverse() |> Enum.find_index(&(&1 in [".", "#"]))) - 1

        x ->
          x
      end

    case row |> Enum.at(next_x) do
      "#" ->
        {:wall, pos}

      " " ->
        {:ok,
         %{
           :x =>
             length(row) - (row |> Enum.reverse() |> Enum.find_index(&(&1 in [".", "#"]))) - 1,
           :y => pos.y
         }}

      _ ->
        {:ok, %{:x => next_x, :y => pos.y}}
    end
  end

  def perform_step(pos, map, facing) when facing == :down do
    next_y = find_row_index_to_step_down(pos.y, pos.x, map)

    case map |> Enum.at(next_y) |> Enum.at(pos.x) do
      "#" -> {:wall, pos}
      _ -> {:ok, %{:x => pos.x, :y => next_y}}
    end
  end

  def perform_step(pos, map, facing) when facing == :up do
    next_y = find_row_index_to_step_up(pos.y, pos.x, map)

    case map |> Enum.at(next_y) |> Enum.at(pos.x) do
      "#" -> {:wall, pos}
      _ -> {:ok, %{:x => pos.x, :y => next_y}}
    end
  end

  def find_row_index_to_step_up(from_y, x, map) do
    rest = map |> Enum.take(from_y)
    len = length(rest)

    rest =
      cond do
        len == 0 -> map
        true -> rest
      end

    next_y = rest |> Enum.reverse() |> Enum.find_index(&((&1 |> Enum.at(x)) in [".", "#"]))

    cond do
      next_y == nil ->
        length(map) - 1 -
          (map |> Enum.reverse() |> Enum.find_index(&((&1 |> Enum.at(x)) in [".", "#"])))

      len == 0 ->
        length(map) - next_y - 1

      true ->
        from_y - 1
    end
  end

  def find_row_index_to_step_down(from_y, x, map) do
    rest = map |> Enum.drop(from_y + 1)
    len = length(rest)

    rest =
      cond do
        len == 0 -> map
        true -> rest
      end

    next_y = rest |> Enum.find_index(&((&1 |> Enum.at(x)) in [".", "#"]))

    cond do
      next_y == nil -> map |> Enum.find_index(&((&1 |> Enum.at(x)) in [".", "#"]))
      len == 0 -> next_y
      true -> next_y + from_y + 1
    end
  end

  def calc_new_direction(current, action) do
    case {current, action} do
      {:right, "R"} -> :down
      {:right, "L"} -> :up
      {:down, "R"} -> :left
      {:down, "L"} -> :right
      {:left, "R"} -> :up
      {:left, "L"} -> :down
      {:up, "R"} -> :right
      {:up, "L"} -> :left
    end
  end

  def get_result(file \\ "input-0.txt") do
    {map, path} =
      file
      |> read_file()

    starting_point = map |> find_starting_point() |> IO.inspect(label: "starting point")

    {pos, direction, _, _} =
      path
      |> Enum.reduce({starting_point, :right, map, 0}, fn p, {pos, direction, mm, idx} ->
        # IO.inspect({p, pos, direction}, label: "process step")

        case p do
          "R" ->
            {pos, calc_new_direction(direction, "R"), mm, idx + 1}

          # |> IO.inspect(label: "R from " <> to_string(direction))

          "L" ->
            {pos, calc_new_direction(direction, "L"), mm, idx + 1}

          # |> IO.inspect(label: "L")

          count ->
            {new_pos, mm} = perform_steps(pos, map, direction, p, mm)
            file_name = "output/output-" <> to_string(idx + 1) <> ".txt"
            # File.write!(file_name, mm |> Enum.join("\n"))
            {new_pos, direction, mm, idx + 1}
            # |> IO.inspect(
            #   label:
            #     to_string(count) <>
            #       " steps from {" <> to_string(pos.x) <> ", " <> to_string(pos.y) <> "}"
            # )
        end
      end)
      |> IO.inspect(label: "final pos")

    (pos.y + 1) * 1000 + 4 * (pos.x + 1) + calc_direction_weight(direction)
  end

  def update_map(map, pos, direction) do
    s =
      case direction do
        :right -> ">"
        :left -> "<"
        :up -> "^"
        :down -> "v"
      end

    map |> List.replace_at(pos.y, map |> Enum.at(pos.y) |> List.replace_at(pos.x, s))
  end

  def calc_direction_weight(direction) do
    case direction do
      :right -> 0
      :down -> 1
      :left -> 2
      :up -> 3
    end
  end

  def find_starting_point(map) do
    %{:x => map |> hd |> Enum.find_index(&(&1 == ".")), :y => 0}
  end

  def read_file(file \\ "input-0.txt") do
    {map, path} =
      file
      |> File.read!()
      |> String.split("\n")
      |> Enum.split_while(&(&1 != ""))

    {map |> Enum.map(&String.graphemes/1),
     path |> tl |> hd |> parse_path |> IO.inspect(label: "path")}
  end

  def parse_path(path) do
    {cur, res} =
      path
      |> String.graphemes()
      |> Enum.reduce({"", []}, fn c, {cur, res} ->
        case c |> Integer.parse() do
          {_, _} ->
            {cur <> c, res}

          :error ->
            cond do
              cur != "" ->
                {"", res ++ [cur |> Integer.parse() |> elem(0)] ++ [c]}

              true ->
                {"", res ++ [c]}
            end
        end
      end)

    cond do
      cur != "" -> res ++ [cur |> Integer.parse() |> elem(0)]
      true -> res
    end
  end
end
