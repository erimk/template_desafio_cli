defmodule DesafioCli.Handler do
  @moduledoc """
  Handler of commands.
  """

  alias DesafioCli.Repo

  defp take_key_value([_, key, value]), do: {:ok, key, value}
  defp take_key_value(_), do: {:error, :wrong_input}

  defp take_key([_, key]), do: {:ok, key}
  defp take_key(_), do: {:error, :wrong_input}

  @spec set(atom(), list(String.t())) :: atom()
  def set(table, command) do
    {:ok, key, value} = take_key_value(command)

    case Repo.upsert(table, key, value) do
      {bool, _key, value} ->
        bool = bool |> Atom.to_string() |> String.upcase()
        IO.puts("#{bool} #{value}")

      _ ->
        IO.puts("ERR <503>")
    end

    table
  end

  @spec get(atom(), list(String.t())) :: atom()
  def get(table, command) do
    {:ok, key} = take_key(command)

    case Repo.select(table, key) do
      nil -> IO.puts("NIL")
      value -> IO.puts("#{value}")
    end

    table
  end

  @spec begin(atom()) :: atom()
  def begin(table) do
    new_table = Repo.transaction(table)
    [_, number] = new_table |> Atom.to_string() |> String.split("a")
    IO.puts("#{number}")

    new_table
  end

  def rollback(table) do
    previous_table = Repo.rollback(table)
    [_, number] = previous_table |> Atom.to_string() |> String.split("a")
    IO.puts("#{number}")

    previous_table
  end

  def commit(table) do
    commited_table = Repo.commit(table)
    [_, number] = commited_table |> Atom.to_string() |> String.split("a")
    IO.puts("#{number}")

    commited_table
  end

  @spec clean(atom()) :: atom()
  def clean(table) do
    :dets.delete_all_objects(table)
    table
  end

  def fallback(table) do
    IO.puts("ERR")
    table
  end
end
