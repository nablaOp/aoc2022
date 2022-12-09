defmodule RR do
  def get_input(fileName) do
    fileName |> File.read!() |> String.split("\n")
  end

  def get_move(s) do
    s |> String.split(" ")
  end

  def get_steps(s) do
    s |> tl |> hd |> Integer.parse() |> elem(0)
  end

  def save_move(res, pos, skip) do
    if !Map.has_key?(res, pos) and !skip do
      Map.merge(res, %{pos => true})
    else
      res
    end
  end

  def is_far?(hi, hj, ti, tj) do
    abs(hi - ti) > 1 or abs(hj - tj) > 1
  end

  def get_t_pos(dir, hi, hj, ti, tj) do
    if is_far?(hi, hj, ti, tj) do
      case dir do
        "R" -> {hi - 1, hj}
        "L" -> {hi + 1, hj}
        "U" -> {hi, hj - 1}
        "D" -> {hi, hj + 1}
      end
    else
      {ti, tj}
    end
  end

  def get_result(fileName) do
    fileName
    |> get_input()
    |> Enum.map(&get_move/1)
    |> calc({{0, 0}, {0, 0}, %{}})
    |> elem(2)
    |> Map.keys()
    |> Enum.count()
  end

  def get_result_part_two(fileName) do
    fileName
    |> get_input()
    |> Enum.map(&get_move/1)
    |> calc_part_two({{0, 0}, Enum.map(1..10, fn _ -> {0, 0} end), %{}})
    |> elem(2)
    |> Map.keys()
    |> Enum.count()
  end

  def make_one_step(dir, h_shift, skip_save, {{h_i, h_j}, {t_i, t_j}, res}) do
    case dir do
      r when r == "R" ->
        t_pos = get_t_pos(r, h_i + 1, h_j, t_i, t_j)
        {{h_i + h_shift, h_j}, t_pos, save_move(res, t_pos, skip_save)}

      l when l == "L" ->
        t_pos = get_t_pos(l, h_i - 1, h_j, t_i, t_j)
        {{h_i - h_shift, h_j}, t_pos, save_move(res, t_pos, skip_save)}

      u when u == "U" ->
        t_pos = get_t_pos(u, h_i, h_j + 1, t_i, t_j)
        {{h_i, h_j + h_shift}, t_pos, save_move(res, t_pos, skip_save)}

      d when d == "D" ->
        t_pos = get_t_pos(d, h_i, h_j - 1, t_i, t_j)
        {{h_i, h_j - h_shift}, t_pos, save_move(res, t_pos, skip_save)}

      _ ->
        {{h_i, h_j}, {t_i, t_j}, res}
    end
  end

  def calc(moves, input) do
    moves
    |> Enum.reduce(input, fn s, acc ->
      1..(s |> get_steps)
      |> Enum.reduce(acc, fn _, acc ->
        make_one_step(s |> hd, 1, false, acc)
      end)
    end)
  end

  def calc_part_two(moves, input) do
    moves
    |> Enum.reduce(input, fn s, acc ->
      1..(s |> get_steps)
      |> Enum.reduce(acc, fn _, acc ->
        1..10
        |> Enum.reduce(acc, fn step, {{h_i, h_j}, t, res} ->
          case step do
            1 ->
              n = make_one_step(s |> hd, 1, true, {{h_i, h_j}, Enum.at(t, step - 1), res})

              {elem(n, 0), List.replace_at(t, step - 1, elem(n, 1)), elem(n, 2)} |> IO.inspect()

            10 ->
              n =
                make_one_step(
                  s |> hd,
                  0,
                  false,
                  {{h_i, h_j}, Enum.at(t, step - 1), res}
                )

              {elem(n, 0), List.replace_at(t, step - 1, elem(n, 1)), elem(n, 2)}

            _ ->
              n =
                make_one_step(
                  s |> hd,
                  0,
                  true,
                  {Enum.at(t, step - 2), Enum.at(t, step - 1), res}
                )

              {elem(n, 0), List.replace_at(t, step - 1, elem(n, 1)), elem(n, 2)}
          end
        end)
      end)
    end)
  end
end

RR.get_result_part_two("input-2.txt") |> IO.inspect()
