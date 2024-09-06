defmodule DesafioCli do
  @moduledoc """
  Ponto de entrada para a CLI.
  """
  alias DesafioCli.Handler

  @doc """
  A função main recebe os argumentos passados na linha de
  comando como lista de strings e executa a CLI.
  """
  def main(_args) do
    {:ok, table} = :dets.open_file(:a0, type: :set)

    menu(table)
  end

  def menu(table) do
    input = IO.gets("> ") |> String.trim()
    command = String.split(input, " ")

    case hd(command) do
      "SET" -> Handler.set(table, command)
      "GET" -> Handler.get(table, command)
      "BEGIN" -> Handler.begin(table)
      "ROLLBACK" -> Handler.rollback(table)
      "COMMIT" -> Handler.commit(table)
      "clean" -> Handler.clean(table)
      _ -> Handler.fallback(table)
    end
    |> menu()
  end
end
