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

  def save_move(res, pos) do
    if !Map.has_key?(res, pos) do
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
    |> Enum.reduce({{0, 0}, {0, 0}, %{}}, fn s, acc ->
      case s |> hd do
        r when r == "R" ->
          1..(s |> get_steps)
          |> Enum.reduce(acc, fn _, {{h_i, h_j}, {t_i, t_j}, res} ->
            t_pos = get_t_pos(r, h_i + 1, h_j, t_i, t_j)
            {{h_i + 1, h_j}, t_pos, save_move(res, t_pos)}
          end)

        l when l == "L" ->
          1..(s |> get_steps)
          |> Enum.reduce(acc, fn _, {{h_i, h_j}, {t_i, t_j}, res} ->
            t_pos = get_t_pos(l, h_i - 1, h_j, t_i, t_j)
            {{h_i - 1, h_j}, t_pos, save_move(res, t_pos)}
          end)

        u when u == "U" ->
          1..(s |> get_steps)
          |> Enum.reduce(acc, fn _, {{h_i, h_j}, {t_i, t_j}, res} ->
            t_pos = get_t_pos(u, h_i, h_j + 1, t_i, t_j)
            {{h_i, h_j + 1}, t_pos, save_move(res, t_pos)}
          end)

        d when d == "D" ->
          1..(s |> get_steps)
          |> Enum.reduce(acc, fn _, {{h_i, h_j}, {t_i, t_j}, res} ->
            t_pos = get_t_pos(d, h_i, h_j - 1, t_i, t_j)
            {{h_i, h_j - 1}, t_pos, save_move(res, t_pos)}
          end)

        _ ->
          acc
      end
    end)
    |> elem(2)
    |> Map.keys()
    |> Enum.count()
  end
end

RR.get_result("input-1.txt") |> IO.inspect()
