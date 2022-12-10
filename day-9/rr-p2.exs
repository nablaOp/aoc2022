defmodule RR do
  def get_input(file) do
    file |> File.read!() |> String.split("\n")
  end

  def get_move(s) do
    r =
      s
      |> String.split(" ")
      |> List.to_tuple()

    %{dir: r |> elem(0), steps: r |> elem(1) |> Integer.parse() |> elem(0)}
  end

  def save_move(res, pos) do
    if !Map.has_key?(res, pos) do
      Map.merge(res, %{pos => true})
    else
      res
    end
  end

  def move_tail({hi, hj}, {ti, tj}) do
    cond do
      abs(hi - ti) > 1 and hj == tj ->
        {ti + (hi - ti) / abs(hi - ti), tj}

      abs(hj - tj) > 1 and hi == ti ->
        {ti, tj + (hj - tj) / abs(hj - tj)}

      abs(hi - ti) > 1 and abs(hj - tj) > 0 ->
        {ti + (hi - ti) / abs(hi - ti), tj + (hj - tj) / abs(hj - tj)}

      abs(hj - tj) > 1 and abs(hi - ti) > 0 ->
        {ti + (hi - ti) / abs(hi - ti), tj + (hj - tj) / abs(hj - tj)}

      true ->
        {ti, tj}
    end
  end

  def move_head(dir, {hi, hj}) do
    case dir do
      "R" -> {hi + 1, hj}
      "L" -> {hi - 1, hj}
      "U" -> {hi, hj + 1}
      "D" -> {hi, hj - 1}
    end
  end

  def get_result(fileName) do
    res =
      fileName
      |> get_input()
      |> Enum.map(&get_move/1)
      |> Enum.reduce(%{h: {0, 0}, t: Enum.map(1..9, fn _ -> {0, 0} end), res: %{}}, fn move,
                                                                                       acc ->
        1..move.steps
        |> Enum.reduce(acc, fn _, acc ->
          1..9
          |> Enum.reduce(acc, fn t, acc ->
            case t do
              1 ->
                %{
                  h: move_head(move.dir, acc.h),
                  t:
                    List.replace_at(
                      acc.t,
                      t - 1,
                      move_tail(move_head(move.dir, acc.h), Enum.at(acc.t, t - 1))
                    ),
                  res: acc.res
                }

              9 ->
                %{
                  h: acc.h,
                  t:
                    List.replace_at(
                      acc.t,
                      t - 1,
                      move_tail(Enum.at(acc.t, t - 2), Enum.at(acc.t, t - 1))
                    ),
                  res: save_move(acc.res, move_tail(Enum.at(acc.t, t - 2), Enum.at(acc.t, t - 1)))
                }

              _ ->
                %{
                  h: acc.h,
                  t:
                    List.replace_at(
                      acc.t,
                      t - 1,
                      move_tail(Enum.at(acc.t, t - 2), Enum.at(acc.t, t - 1))
                    ),
                  res: acc.res
                }
            end
          end)
        end)
      end)

    res.res |> Map.to_list() |> Enum.count()
  end
end

RR.get_result("input-1.txt") |> IO.inspect()
