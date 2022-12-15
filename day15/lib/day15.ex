defmodule Day15 do
  def get_sensor_area({si, sj}, {bi, bj}, area) do
    d = abs(si - bi) + abs(sj - bj)

    area
    |> Map.merge(%{{si, sj} => :S})
    |> Map.merge(%{{bi, bj} => :B})
    |> build_area({si, sj}, d)
  end

  def build_area(area, {si, sj}, max) do
    case max do
      max when max > 0 ->
        area
        |> Map.merge(
          (si - max)..(si + max)
          |> Enum.reduce(area, fn i, acc ->
            cond do
              acc |> Map.has_key?({i, sj}) ->
                acc

              true ->
                acc |> Map.merge(%{{i, sj} => :O})
            end
          end)
        )
        |> Map.merge(build_area(area, {si, sj - 1}, max - 1))
        |> Map.merge(build_area(area, {si, sj + 1}, max - 1))

      _ ->
        area
    end
  end

  def get_result_o(file, idx) do
    data =
      file
      |> get_input()
      |> Enum.map(fn r -> parse_row(r) end)

    area =
      data
      |> Enum.reduce({nil, nil}, fn [s, b], acc ->
        acc = get_sensor_area_o(acc, s, b, idx)
      end)

    beacons = data |> Enum.filter(fn i -> i |> tl |> hd == idx end) |> Enum.count()

    elem(area, 1) - elem(area, 0) - beacons
  end

  def get_sensor_area_o({rmin, rmax}, {si, sj}, {bi, bj}, idx) do
    d = abs(si - bi) + abs(sj - bj)

    build_area_oo({rmin, rmax}, {si, sj}, d, idx)
  end

  def build_area_oo({rmin, rmax}, {si, sj}, max, idx) do
    delta = abs(sj - idx)

    cond do
      delta <= max ->
        # IO.inspect({si, sj, max, delta})

        {rmin, rmax} =
          case {si, idx} do
            {si, idx} when si - max + delta < rmin or rmin == nil -> {si - max + delta, rmax}
            _ -> {rmin, rmax}
          end

        case {si, idx} do
          {si, idx} when si + max - delta > rmax or rmax == nil -> {rmin, si + max - delta}
          _ -> {rmin, rmax}
        end

      true ->
        {rmin, rmax}
    end
  end

  def build_area_o({rmin, rmax}, {si, sj}, max, idx) do
    case {sj, max} do
      {sj, _} when sj != idx and max > 0 ->
        res = build_area_o({rmin, rmax}, {si, sj - 1}, max - 1, idx)
        build_area_o(res, {si, sj + 1}, max - 1, idx)

      {sj, max} when max > 0 ->
        {rmin, rmax} =
          case {si, idx} do
            {si, idx} when si - max < rmin or rmin == nil -> {si - max, rmax}
            _ -> {rmin, rmax}
          end

        {rmin, rmax} =
          case {si, idx} do
            {si, idx} when si + max > rmax or rmax == nil -> {rmin, si + max}
            _ -> {rmin, rmax}
          end

        {rmin, rmax} = build_area_o({rmin, rmax}, {si, sj - 1}, max - 1, idx)
        build_area_o({rmin, rmax}, {si, sj + 1}, max - 1, idx)

      _ ->
        {rmin, rmax}
    end
  end

  def get_result(file, idx) do
    area =
      file
      |> get_input()
      |> Enum.map(fn r -> parse_row(r) end)
      |> Enum.reduce(%{}, fn [s, j], acc ->
        acc |> Map.merge(get_sensor_area(s, j, acc))
      end)

    area
    |> Map.keys()
    |> Enum.filter(fn {i, j} -> j == idx end)
    |> Enum.map(fn k -> Map.fetch(area, k) |> elem(1) end)
    |> Enum.filter(fn i -> i == :O end)
    |> Enum.count()
  end

  def parse_row(r) do
    # Sensor at x=2, y=18: closest beacon is at x=-2, y=15
    r
    |> String.replace("Sensor at ", "")
    |> String.replace("x=", "")
    |> String.replace("y=", "")
    |> String.replace(" closest beacon is at ", "")
    |> String.split(":")
    |> Enum.map(fn i ->
      i
      |> String.split(",")
      |> Enum.map(fn n -> n |> String.trim() |> Integer.parse() |> elem(0) end)
      |> List.to_tuple()
    end)
  end

  def get_input(file) do
    file
    |> File.read!()
    |> String.split("\n")
  end
end
