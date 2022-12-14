defmodule Day13Test do
  use ExUnit.Case
  doctest Day13

  test "input 0" do
    assert Day13.get_result("input-0.txt") == 13
  end

  test "input 1" do
    assert Day13.get_result("input-1.txt") == 1
  end

  test "check integers" do
    assert Day13.check_integers(1, 2) == true
    assert Day13.check_integers(2, 1) == false
    assert Day13.check_integers(2, 2) == :continue
  end

  test "check arrays" do
    assert Day13.check_arrays([1, 1, 3, 1, 1], [1, 1, 5, 1, 1]) == true
    assert Day13.check_arrays([7, 7, 7, 7], [7, 7, 7]) == false
    assert Day13.check_arrays([], [3]) == true
  end

  test "check" do
    assert Day13.check([1, [2, [3, [4, [5, 6, 7]]]], 8, 9], [1, [2, [3, [4, [5, 6, 0]]]], 8, 9]) ==
             false
  end
end
