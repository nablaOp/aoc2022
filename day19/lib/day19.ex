defmodule Day19 do
  @moduledoc """
  Documentation for `Day19`.
  """

  def collect_resources(factory) do
    factory = %{factory | ore: factory.ore + factory.ore_robot}
    factory = %{factory | clay: factory.clay + factory.clay_robot}
    factory = %{factory | obsidian: factory.obsidian + factory.obsidian_robot}
    factory = %{factory | geode: factory.geode + factory.geode_robot}
  end

  def init_factory() do
    %{
      :ore => 0,
      :clay => 0,
      :obsidian => 0,
      :geode => 0,
      :ore_robot => 1,
      :clay_robot => 0,
      :obsidian_robot => 0,
      :geode_robot => 0
    }
  end

  def build_robots(factory, blueprint) do
    new_robot = try_build_robot(factory, blueprint)

    case new_robot do
      {:none, _, _, _} ->
        factory

      {type, ore, clay, obsidian} ->
        factory = %{factory | ore: factory.ore - ore}
        factory = %{factory | clay: factory.clay - clay}
        factory = %{factory | obsidian: factory.obsidian - obsidian}
        factory = factory |> Map.update!(type, fn i -> i + 1 end)
        # build_robots(factory, blueprint)
    end
  end

  def try_build_robot(factory, blueprint) do
    case {factory.ore, factory.clay, factory.obsidian} do
      {ore, _, obsidian}
      when ore >= blueprint.geode |> elem(0) and obsidian >= blueprint.geode |> elem(1) ->
        {:geode_robot, blueprint.geode |> elem(0), 0, blueprint.geode |> elem(1)}

      {ore, clay, _}
      when ore >= blueprint.obsidian |> elem(0) and clay >= blueprint.obsidian |> elem(1) and
             (blueprint.obsidian_max == 0 or factory.obsidian_robot <= blueprint.obsidian_max) ->
        {:obsidian_robot, blueprint.obsidian |> elem(0), blueprint.obsidian |> elem(1), 0}

      {ore, _, _}
      when ore >= blueprint.clay and
             (blueprint.clay_max == 0 or factory.clay_robot + 1 <= blueprint.clay_max) ->
        {:clay_robot, blueprint.clay, 0, 0}

      {ore, _, _}
      when ore >= blueprint.ore and
             (blueprint.ore_max == 0 or factory.ore_robot <= blueprint.ore_max) ->
        {:ore_robot, blueprint.ore, 0, 0}

      _ ->
        {:none, 0, 0, 0}
    end
  end

  def apply_blueprint_for_factory(blueprint, minutes) do
    IO.inspect(blueprint, label: "blueprint")

    factory =
      1..minutes
      |> Enum.reduce(init_factory(), fn m, acc ->
        # build robots
        # collect resource (no new robots use)
        # update robots count
        updated_by_robots = build_robots(acc, blueprint)
        acc = %{acc | ore: updated_by_robots.ore}
        acc = %{acc | clay: updated_by_robots.clay}
        acc = %{acc | obsidian: updated_by_robots.obsidian}
        acc = collect_resources(acc)
        acc = %{acc | ore_robot: updated_by_robots.ore_robot}
        acc = %{acc | clay_robot: updated_by_robots.clay_robot}
        acc = %{acc | obsidian_robot: updated_by_robots.obsidian_robot}
        acc = %{acc | geode_robot: updated_by_robots.geode_robot}
        acc
      end)

    IO.inspect(factory, label: "factory")

    case {factory.clay_robot, factory.obsidian_robot, factory.geode_robot} do
      {0, _, _} ->
        IO.inspect(%{blueprint | ore_max: factory.ore_robot - 1}, label: "no clay robots")
        apply_blueprint_for_factory(%{blueprint | ore_max: factory.ore_robot - 1}, minutes)

      {_, 0, _} ->
        IO.inspect(%{blueprint | clay_max: factory.clay_robot - 1}, label: "no obsidian robots")
        apply_blueprint_for_factory(%{blueprint | clay_max: factory.clay_robot - 1}, minutes)

      {_, _, 0} ->
        IO.inspect(%{blueprint | clay_max: factory.clay_robot - 1}, label: "no geode robots")

        apply_blueprint_for_factory(%{blueprint | clay_max: factory.clay_robot - 1}, minutes)

      {_, _, g} when g >= blueprint.geode_max ->
        blueprint = %{blueprint | clay_max: factory.clay_robot - 1}
        blueprint = %{blueprint | geode_max: g}
        apply_blueprint_for_factory(blueprint, minutes)

      _ ->
        factory
    end

    # cond do
    #   blueprint.geode_max == 0 or factory.geode_robot == 0 or
    #       factory.geode_robot > factory.geode_robot ->
    #     blueprint = %{blueprint | max_geode: factory.geode_robot}

    #   true ->
    #     factory
    # end
  end

  def get_result(file \\ "input-0.txt", minutes) do
    blueprints =
      file
      |> get_input()
      |> parse_input()

    blueprints
    |> Enum.reduce(%{}, fn bl, acc ->
      acc
      |> Map.put_new(
        bl.id,
        apply_blueprint_for_factory(bl, minutes)
      )
    end)
  end

  def get_input(file) do
    file
    |> File.read!()
    |> String.split("\n")
  end

  def parse_input(input) do
    input
    |> Enum.reduce([], fn i, acc ->
      # Blueprint 1: Each ore robot costs 4 ore. Each clay robot costs 2 ore. Each obsidian robot costs 3 ore and 14 clay. Each geode robot costs 2 ore and 7 obsidian.
      data =
        i
        |> String.replace("Blueprint ", "")
        |> String.replace(" Each ore robot costs ", "")
        |> String.replace(" Each clay robot costs ", "")
        |> String.replace(" Each obsidian robot costs ", "")
        |> String.replace(" Each geode robot costs ", "")
        |> String.replace(" ore", "")
        |> String.replace(" clay", "")
        |> String.replace(" obsidian", "")
        |> String.replace(" ", "")

      [id, rest] = data |> String.split(":")
      costs = rest |> String.split(".")

      acc ++
        [
          %{
            :id => id |> Integer.parse() |> elem(0),
            :ore => costs |> Enum.at(0) |> Integer.parse() |> elem(0),
            :clay => costs |> Enum.at(1) |> Integer.parse() |> elem(0),
            :obsidian =>
              costs
              |> Enum.at(2)
              |> String.split("and")
              |> Enum.map(fn i -> i |> Integer.parse() |> elem(0) end)
              |> List.to_tuple(),
            :geode =>
              costs
              |> Enum.at(3)
              |> String.split("and")
              |> Enum.map(fn i -> i |> Integer.parse() |> elem(0) end)
              |> List.to_tuple(),
            :ore_max => 0,
            :clay_max => 0,
            :obsidian_max => 0,
            :geode_max => 0
          }
        ]
    end)
  end
end
