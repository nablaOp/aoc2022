defmodule Day21Test do
  use ExUnit.Case
  doctest Day21

  test "simple operation" do
    assert Day21.apply_operation({3, "+", 2}) == 5
  end

  test "advanced operation" do
    assert Day21.apply_operation({{3, "+", 3}, "/", 2}) == 3
  end

  test "parse line" do
    assert Day21.parse_line("root: pppw + sjmn") == %{
             :name => "root",
             :operation => {"pppw", "+", "sjmn"}
           }

    assert Day21.parse_line("dbpl: 5") == %{"dbpl" => 5}
  end

  test "build" do
    input = %{"root" => {3, "+", "aaa"}, "aaa" => 3}
    assert Day21.build(input) == {3, "+", 3}
  end
end
