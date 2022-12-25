defmodule Day23Test do
  use ExUnit.Case
  doctest Day23

  test "move intentions" do
    {map, elves} = Day23.read_file() |> Day23.parse_map_elves()

    assert Day23.plan_to_go?({2, 1}, map, [:north, :south, :west, :east]) == {2, 0}
  end
end
