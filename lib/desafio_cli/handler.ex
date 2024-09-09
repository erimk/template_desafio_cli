defmodule DesafioCli.Handler do
  @moduledoc """
  Handler of commands.
  All public functions here are designed to receive table, handle it and return the handled table.
  """

  alias DesafioCli.Repo

  @spec take_key_value(list()) :: {atom(), String.t(), Repo.value()} | {:error, :wrong_input}
  defp take_key_value([_, key, value]), do: {:ok, key, value}
  defp take_key_value(_), do: {:error, :wrong_input}

  defp take_key([_, key]), do: {:ok, key}
  defp take_key(_), do: {:error, :wrong_input}

  @spec set(atom(), list(String.t())) :: atom()
  def set(table, command) do
    with {:ok, key, value} <- take_key_value(command),
         {bool, _key, value} <- Repo.upsert(table, key, value) do
      bool = bool |> Atom.to_string() |> String.upcase()
      IO.puts("#{bool} #{format_bool(value)}")
    else
      :error ->
        IO.puts("ERR SET error")
        table

      {:error, :wrong_input} ->
        IO.puts(~s(ERR "SET <chave> <valor> - Syntax error"))
        table
    end

    table
  end

  @spec get(atom(), list(String.t())) :: atom()
  def get(table, command) do
    with {:ok, key} <- take_key(command),
         {:ok, value} <- Repo.select(table, key) do
      IO.puts("#{format_bool(value)}")
    else
      {:error, :not_found} ->
        IO.puts("NIL")
        table

      {:error, :wrong_input} ->
        IO.puts("ERR \"GET <chave> - Syntax error\"")
        table
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

  @spec rollback(atom()) :: atom()
  def rollback(table) do
    case Repo.undo(table) do
      {:ok, previous_table} ->
        [_, number] = previous_table |> Atom.to_string() |> String.split("a")
        IO.puts("#{number}")

        previous_table

      {:error, _} ->
        IO.puts("No transaction open to rollback.")

        table
    end
  end

  @spec commit(atom()) :: atom()
  def commit(table) do
    commited_table = Repo.exec(table)
    [_, number] = commited_table |> Atom.to_string() |> String.split("a")
    IO.puts("#{number}")

    commited_table
  end

  @spec clean(atom()) :: atom()
  def clean(table) do
    :dets.delete_all_objects(table)
    table
  end

  @spec fallback(atom(), list()) :: atom()
  def fallback(table, [""]) do
    IO.puts("ERR \"No command found.\"")
    table
  end

  def fallback(table, command) do
    IO.puts("ERR \"No command #{command}\"")
    table
  end

  defp format_bool(var) when is_boolean(var), do: to_string(var) |> String.upcase()
  defp format_bool(var), do: var
end
