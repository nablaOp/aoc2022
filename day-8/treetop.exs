defmodule TT do
  def get_matrix(fileName) do
    fileName
    |> File.read!()
    |> String.split("\n")
    |> Enum.map(fn i ->
      i
      |> String.split("")
      |> Enum.filter(fn i -> i != "" end)
      |> Enum.map(fn i ->
        i
        |> Integer.parse()
        |> elem(0)
      end)
    end)
  end

  def get_result(fileName) do
    matrix =
      fileName
      |> get_matrix()

    matrix
    |> Enum.reduce({0, 0, 0}, fn r, {rres, ri, rj} ->
      r
      |> Enum.reduce({rres, ri + 1, 0}, fn c, {cres, ci, cj} ->
        # IO.inspect(%{:i => ci - 1, :j => cj, :r => is_high_enough(matrix, ci - 1, cj, c)})

        {
          if is_high_enough(matrix, ci - 1, cj, c) |> Tuple.to_list() |> Enum.member?(true) do
            cres + 1
          else
            cres
          end,
          ci,
          cj + 1
        }
      end)
    end)
  end

  def get_result_partTwo(fileName) do
    matrix =
      fileName
      |> get_matrix()

    matrix
    |> Enum.reduce({0, 0, 0}, fn r, {rres, ri, rj} ->
      r
      |> Enum.reduce({rres, ri + 1, 0}, fn c, {cres, ci, cj} ->
        # IO.inspect(%{:i => ci - 1, :j => cj, :r => is_high_enough(matrix, ci - 1, cj, c)})
        new_res =
          how_many_you_see(matrix, ci - 1, cj, c)
          |> Tuple.to_list()
          |> Enum.map(fn i ->
            if is_tuple(i) do
              elem(i, 0)
            else
              i
            end
          end)
          |> Enum.product()

        {
          if new_res > cres do
            new_res
          else
            cres
          end,
          ci,
          cj + 1
        }
      end)
    end)
  end

  def is_high_enough(m, input_i, input_j, v) do
    m
    |> Enum.reduce({{true, true, true, true}, 0, 0}, fn r, {rres, ri, rj} ->
      r
      |> Enum.reduce({rres, ri + 1, 0}, fn c, {cres, ci, cj} ->
        # IO.inspect({ci - 1, cj, c, v})

        case {ci - 1, cj} do
          {ti, tj} when ti == input_i and tj == input_j ->
            {cres, ci, cj + 1}

          {ti, tj} when ti < input_i and tj == input_j and c >= v ->
            {{false, elem(cres, 1), elem(cres, 2), elem(cres, 3)}, ci, cj + 1}

          {ti, tj} when ti > input_i and tj == input_j and c >= v ->
            {{elem(cres, 0), false, elem(cres, 2), elem(cres, 3)}, ci, cj + 1}

          {ti, tj} when ti == input_i and tj < input_j and c >= v ->
            {{elem(cres, 0), elem(cres, 1), false, elem(cres, 3)}, ci, cj + 1}

          {ti, tj} when ti == input_i and tj > input_j and c >= v ->
            {{elem(cres, 0), elem(cres, 1), elem(cres, 2), false}, ci, cj + 1}

          _ ->
            {cres, ci, cj + 1}
        end

        # |> IO.inspect()
      end)
    end)
    |> elem(0)
  end

  def how_many_you_see(m, input_i, input_j, v) do
    # IO.inspect(%{:i => input_i, :j => input_j, :v => v})

    m
    |> Enum.reduce({{0, {0, false}, 0, {0, false}}, 0, 0}, fn r, {rres, ri, rj} ->
      r
      |> Enum.reduce({rres, ri + 1, 0}, fn c, {cres, ci, cj} ->
        # IO.inspect({ci - 1, cj, c, v})

        case {ci - 1, cj} do
          {ti, tj} when ti == input_i and tj == input_j ->
            {cres, ci, cj + 1}

          {ti, tj} when ti < input_i and tj == input_j and c >= v ->
            {{1, elem(cres, 1), elem(cres, 2), elem(cres, 3)}, ci, cj + 1}

          # {ti, tj} when ti < input_i and tj == input_j and c == v ->
          #   {{1, elem(cres, 1), elem(cres, 2), elem(cres, 3)}, ci, cj + 1}

          {ti, tj} when ti < input_i and tj == input_j ->
            {{elem(cres, 0) + 1, elem(cres, 1), elem(cres, 2), elem(cres, 3)}, ci, cj + 1}

          {ti, tj}
          when ti > input_i and tj == input_j and c < v and cres |> elem(1) |> elem(1) == false ->
            {{
               elem(cres, 0),
               {(cres |> elem(1) |> elem(0)) + 1, false},
               elem(cres, 2),
               elem(cres, 3)
             }, ci, cj + 1}

          # {ti, tj}
          # when ti > input_i and tj == input_j and c == v and cres |> elem(1) |> elem(1) == false ->
          #   {{
          #      elem(cres, 0),
          #      {(cres |> elem(1) |> elem(0)) + 1, true},
          #      elem(cres, 2),
          #      elem(cres, 3)
          #    }, ci, cj + 1}

          {ti, tj}
          when ti > input_i and tj == input_j and c >= v and cres |> elem(1) |> elem(1) == false ->
            {{
               elem(cres, 0),
               {(cres |> elem(1) |> elem(0)) + 1, true},
               elem(cres, 2),
               elem(cres, 3)
             }, ci, cj + 1}

          {ti, tj} when ti == input_i and tj < input_j and c >= v ->
            {{elem(cres, 0), elem(cres, 1), 1, elem(cres, 3)}, ci, cj + 1}

          # {ti, tj} when ti == input_i and tj < input_j and c == v ->
          #   {{elem(cres, 0), elem(cres, 1), 1, elem(cres, 3)}, ci, cj + 1}

          {ti, tj} when ti == input_i and tj < input_j ->
            {{elem(cres, 0), elem(cres, 1), elem(cres, 2) + 1, elem(cres, 3)}, ci, cj + 1}

          {ti, tj}
          when ti == input_i and tj > input_j and c < v and cres |> elem(3) |> elem(1) == false ->
            {{
               elem(cres, 0),
               elem(cres, 1),
               elem(cres, 2),
               {(cres |> elem(3) |> elem(0)) + 1, false}
             }, ci, cj + 1}

          # {ti, tj}
          # when ti == input_i and tj > input_j and c == v and cres |> elem(3) |> elem(1) == false ->
          #   {{
          #      elem(cres, 0),
          #      elem(cres, 1),
          #      elem(cres, 2),
          #      {(cres |> elem(3) |> elem(0)) + 1, true}
          #    }, ci, cj + 1}

          {ti, tj}
          when ti == input_i and tj > input_j and c >= v and cres |> elem(3) |> elem(1) == false ->
            {{
               elem(cres, 0),
               elem(cres, 1),
               elem(cres, 2),
               {(cres |> elem(3) |> elem(0)) + 1, true}
             }, ci, cj + 1}

          _ ->
            {cres, ci, cj + 1}
        end

        # |> IO.inspect()
      end)
    end)
    |> elem(0)

    # |> IO.inspect()
  end
end
