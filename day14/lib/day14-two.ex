defmodule Day14Two do
  def get_result(file) do
    map =
      file
      |> get_input()
      |> build_map()

    known_area = map |> get_known_area

    {known_area}

    res =
      pour_sand(known_area, map)
      |> elem(1)
      |> Map.values()
      |> Enum.filter(fn i -> i == "O" end)
      |> Enum.count()

    res + 1
  end

  def pour_sand(known_area, map) do
    case make_step({500, 0}, known_area, map) do
      {:ok, _, new_map} -> pour_sand(known_area, new_map)
      {:abyss, _, map} -> {:ok, map}
    end
  end

  def make_step({i, j}, known_area, map) do
    step_res =
      [{0, 1}, {-1, 1}, {1, 1}]
      |> Enum.reduce({:ok, {i, j}, map}, fn {di, dj}, {res, {i, j}, map} ->
        case res do
          :abyss ->
            {res, {i, j}, map}

          _ ->
            case blocked?({i + di, j + dj}, known_area, map) do
              true ->
                {:blocked, {i, j}, map}

              _ ->
                make_step({i + di, j + dj}, known_area, map)
            end
        end
      end)

    case step_res do
      {:blocked, {li, lj}, map} when {li, lj} == {500, 0} -> {:abyss, {li, lj}, map}
      {:blocked, {li, lj}, map} -> {:ok, {li, lj}, map |> Map.merge(%{{li, lj} => "O"})}
      r -> r
    end
  end

  def get_input(file) do
    file
    |> File.read!()
    |> String.split("\n")
    |> Enum.map(fn i ->
      i
      |> String.split(" -> ")
      |> Enum.map(fn j ->
        j |> String.split(",") |> Enum.map(fn k -> k |> Integer.parse() |> elem(0) end)
      end)
    end)
  end

  def build_map(input) do
    input
    |> Enum.reduce(%{}, fn i, acc ->
      i
      |> Enum.reduce({[], %{}}, fn j, {prev, res} ->
        case length(prev) do
          0 -> {j, res}
          _ -> {j, res |> build_rock(prev, j)}
        end
      end)
      |> elem(1)
      |> Map.merge(acc)
    end)
  end

  def build_rock(map, [li, lj], [ri, rj]) do
    li..ri
    |> Enum.reduce(map, fn i, acc ->
      lj..rj
      |> Enum.reduce(acc, fn j, acc ->
        acc |> Map.merge(%{{i, j} => "#"})
      end)
    end)
  end

  def get_known_area(map) do
    f =
      map
      |> Map.keys()
      |> Enum.map(fn k -> k |> elem(1) end)
      |> Enum.reduce(0, fn k, f ->
        case k do
          k when f == 0 -> k
          k when k > f -> k
          _ -> f
        end
      end)

    f + 2
  end

  def blocked?({ti, tj}, known_area, map) do
    map |> Map.has_key?({ti, tj}) or tj == known_area
  end
end
