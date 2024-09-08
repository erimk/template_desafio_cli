defmodule DesafioCli.Repo do
  @moduledoc "Repo"

  @type value :: String.t() | integer() | boolean()

  def init_table, do: :dets.open_file(:a0, type: :set)

  @spec upsert(atom(), atom(), value()) :: {atom(), String.t(), value()} | :error
  def upsert(:a0, key, value) do
    case :dets.insert_new(:a0, {key, value}) do
      true -> {false, key, value}
      false -> {true, key, value}
      _ -> :error
    end
  end

  @spec upsert(atom(), atom(), value()) :: {atom(), String.t(), value()} | :error
  def upsert(table, key, value) do
    if :ets.insert_new(table, {key, value}),
      do: {false, key, value},
      else: {true, key, value}
  end

  @spec select(atom(), String.t()) :: {:ok, value()} | {:error, :not_found}
  def select(:a0, key) do
    case :dets.lookup(:a0, key) do
      [] -> {:error, :not_found}
      [{_, value}] -> {:ok, value}
    end
  end

  def select(table, key) do
    case :ets.lookup(table, key) do
      [] -> {:error, :not_found}
      [{_, value}] -> {:ok, value}
    end
  end

  def transaction(table) do
    new_name = next_name(table)
    new_table = :ets.new(new_name, [:set, :named_table])

    case table do
      :a0 ->
        :dets.to_ets(table, new_table)

      _ ->
        :ets.foldl(fn {key, value}, _ -> :ets.insert(new_table, {key, value}) end, nil, table)
    end

    new_table
  end

  def undo(:a0), do: {:error, :cant_rollback}

  def undo(table) do
    :ets.delete(table)

    {:ok, previous_name(table)}
  end

  def exec(table) do
    case previous_name(table) do
      :a0 ->
        :ets.to_dets(table, :a0)

      old_table ->
        :ets.foldl(fn {key, value}, _ -> :ets.insert(old_table, {key, value}) end, nil, table)
        old_table
    end
  end

  def next_name(name) do
    [_, number] = name |> Atom.to_string() |> String.split("a")
    next = String.to_integer(number) + 1

    to_atom("a#{next}")
  end

  def previous_name(name) do
    [_, number] = name |> Atom.to_string() |> String.split("a")
    previous = String.to_integer(number) - 1

    to_atom("a#{previous}")
  end

  def to_atom(str) do
    String.to_existing_atom(str)
  rescue
    _ -> String.to_atom(str)
  end
end
