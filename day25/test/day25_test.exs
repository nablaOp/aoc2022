defmodule Day25Test do
  use ExUnit.Case
  doctest Day25

  test "get result from input 1" do
    assert Day25.get_result("input-1.txt") == "2=000=22-0-102=-1001"
  end

  test "parse from 10 to 5" do
    assert Day25.from_10_to_5(1) == "1"
    assert Day25.from_10_to_5(8) == "2="
    assert Day25.from_10_to_5(18) == "1-="
    assert Day25.from_10_to_5(2022) == "1=11-2"
    assert Day25.from_10_to_5(314_159_265) == "1121-1110-1=0"
  end

  test "parse from 5 to 10" do
    assert Day25.to_10("1-=") == 18
    assert Day25.to_10("2=-01") == 976
    assert Day25.to_10("1=-0-2") == 1747
    assert Day25.to_10("12111") == 906
    assert Day25.to_10("2=0=") == 198
    assert Day25.to_10("21") == 11
    assert Day25.to_10("2=01") == 201
    assert Day25.to_10("111") == 31
    assert Day25.to_10("20012") == 1257
    assert Day25.to_10("112") == 32
    assert Day25.to_10("1=-1=") == 353
    assert Day25.to_10("1-12") == 107
    assert Day25.to_10("12") == 7
    assert Day25.to_10("1=") == 3
    assert Day25.to_10("122") == 37
  end
end
