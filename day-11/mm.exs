defmodule MM do
  def read_file(file) do
    file |> File.read!() |> String.split("\n")
  end

  def parse_int(s) do
    s |> Integer.parse() |> elem(0)
  end

  def get_id(s) do
    Regex.run(~r/^Monkey \s*(\d+):$/, s) |> List.last() |> parse_int()
  end

  def get_items(s) do
    s
    |> String.split(": ")
    |> List.last()
    |> String.split(", ")
    |> Enum.map(&(&1 |> parse_int))
  end

  def get_operation(s) do
    s
    |> String.split(": ")
    |> List.last()
    |> String.split("= ")
    |> List.last()
    |> String.split(" ")
    |> List.to_tuple()
  end

  def get_test(s) do
    s
    |> String.split(" ")
    |> List.last()
    |> parse_int()
  end

  def get_throw_to(s) do
    s
    |> String.split(" ")
    |> List.last()
    |> parse_int()
  end

  def get_input(file) do
    file
    |> read_file()
    |> Enum.reduce(%{step: 1, current: %{inspections: 0}, input: []}, fn r, acc ->
      cond do
        r == "" ->
          acc

        true ->
          t =
            acc
            |> Map.put(:step, acc.step + 1)

          case rem(acc.step, 6) do
            1 ->
              t |> Map.put(:current, acc.current |> Map.put(:id, get_id(r)))

            2 ->
              t |> Map.put(:current, acc.current |> Map.put(:items, get_items(r)))

            3 ->
              t |> Map.put(:current, acc.current |> Map.put(:operation, get_operation(r)))

            4 ->
              t |> Map.put(:current, acc.current |> Map.put(:test, get_test(r)))

            5 ->
              t |> Map.put(:current, acc.current |> Map.put(:test_true, get_throw_to(r)))

            0 ->
              i = t |> Map.put(:current, acc.current |> Map.put(:test_false, get_throw_to(r)))
              i |> Map.put(:input, i.input ++ [i.current]) |> Map.put(:current, %{inspections: 0})

            _ ->
              t
          end
      end
    end)
    |> Map.get(:input)
  end

  def get_value_for_operation(i, current) do
    case i do
      "old" -> current
      n -> n |> parse_int()
    end
  end

  def change_level(current, {l, o, r}) do
    ln = l |> get_value_for_operation(current)
    rn = r |> get_value_for_operation(current)

    case o do
      "+" -> ln + rn
      "-" -> ln - rn
      "*" -> ln * rn
      "/" -> ln / rn
    end
  end

  def divide_level(n, divider) do
    cond do
      divider == 0 ->
        :math.floor(n / 3)

      true ->
        rem(n, divider)
    end
    |> trunc()
  end

  def make_test(n, by) do
    rem(n, by) == 0
  end

  def make_inspect(item, monkey, divider) do
    level =
      item
      |> change_level(monkey.operation)
      |> divide_level(divider)

    cond do
      make_test(level, monkey.test) -> {monkey.test_true, level}
      true -> {monkey.test_false, level}
    end
  end

  def make_inspect_by_monkey(monkey, divider) do
    monkey.items
    |> Enum.reduce([], fn i, acc ->
      acc ++ [make_inspect(i, monkey, divider)]
    end)
  end

  def make_round_by_monkey(input, divider) do
    0..(length(input) - 1)
    |> Enum.reduce(input, fn idx, acc ->
      current = Enum.at(acc, idx)
      throws = current |> make_inspect_by_monkey(divider)

      newCurrent =
        current
        |> Map.put(:items, [])
        |> Map.put(:inspections, current.inspections + length(throws))

      List.replace_at(acc, idx, newCurrent)
      |> process_throws(throws)
    end)
  end

  def process_throws(input, throws) do
    throws
    |> Enum.reduce(input, fn t, acc ->
      current = Enum.at(acc, elem(t, 0))
      List.replace_at(acc, elem(t, 0), Map.put(current, :items, current.items ++ [elem(t, 1)]))
    end)
  end

  def get_result(file, rounds, second) do
    input =
      file
      |> get_input()

    divider =
      cond do
        second -> input |> Enum.map(fn i -> i.test end) |> Enum.product()
        true -> 0
      end

    1..rounds
    |> Enum.reduce(input, fn _, acc ->
      make_round_by_monkey(acc, divider)
    end)
    |> Enum.map(fn i -> i.inspections end)
    |> Enum.sort(:desc)
    |> Enum.take(2)
    |> Enum.product()
  end
end
