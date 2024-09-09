defmodule DesafioCli.Repo do
  @moduledoc """

  """
  @type value :: String.t() | integer() | boolean()

  @doc """
  Create a dets table and returns it's name.
  """
  @spec init_table() :: {:ok, atom()} | {:erro, atom()}
  def init_table, do: :dets.open_file(:a0, type: :set)

  @doc """
  Do the upsert of a key and a value in a given table.
  The function define the value of a key. If the key never existed,
  it must be created returning false. If the key already exists,
  it will overwritten the new value and return true.
  """
  @spec upsert(atom(), any(), value()) :: {boolean(), String.t(), value()} | :error
  def upsert(:a0, key, value) do
    case select(:a0, key) do
      {:ok, _value} ->
        :ok = :dets.insert(:a0, {key, value})
        {true, key, value}

      {:error, :not_found} ->
        :ok = :dets.insert(:a0, {key, value})
        {false, key, value}
    end
  rescue
    _ -> :error
  end

  def upsert(table, key, value) do
    case select(table, key) do
      {:ok, _value} ->
        :ets.insert(table, {key, value})
        {true, key, value}

      {:error, :not_found} ->
        :ets.insert(table, {key, value})
        {false, key, value}
    end
  end

  @doc """
  Search for the value of a key in a given table name.
  Returns the value if found or an error if not found.
  """
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

  @doc """
  Begins a new transaction creating a new ets table with the exiting values of a given table.
  Returns the new table name.
  """
  @spec transaction(atom()) :: atom()
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

  @doc """
  Cancels a transaction deleting the created ets table.
  Returns the previous table name
  """
  @spec undo(atom()) :: {:ok, atom()} | {:error, :cant_rollback}
  def undo(:a0), do: {:error, :cant_rollback}

  def undo(table) do
    :ets.delete(table)

    {:ok, previous_name(table)}
  end

  @doc """
  Confirm the open transaction, mergint all the values in the previous table.
  Returns the previous table name.
  """
  @spec exec(atom()) :: atom()
  def exec(table) do
    case previous_name(table) do
      :a0 ->
        :ets.to_dets(table, :a0)

      old_table ->
        :ets.foldl(fn {key, value}, _ -> :ets.insert(old_table, {key, value}) end, nil, table)
        old_table
    end
  end

  defp next_name(name) do
    [_, number] = name |> Atom.to_string() |> String.split("a")
    next = String.to_integer(number) + 1

    to_atom("a#{next}")
  end

  defp previous_name(name) do
    [_, number] = name |> Atom.to_string() |> String.split("a")
    previous = String.to_integer(number) - 1

    to_atom("a#{previous}")
  end

  defp to_atom(str) do
    String.to_existing_atom(str)
  rescue
    _ -> String.to_atom(str)
  end
end
