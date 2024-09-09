defmodule DesafioCli.Utils do
  @moduledoc """
  Utils for input command treatment
  """
  alias DesafioCli.Repo

  @doc """
  WIP
  """
  @spec get_command(String.t()) :: list(Repo.value())
  def get_command(str) do
    case find_comm(str) do
      "SET" ->
        [find_comm(str), "#{find_key(str)}", find_value(str)]

      "GET" ->
        [find_comm(str), "#{find_key(str)}"]

      _ ->
        [find_comm(str)]
    end
  end

  defp find_comm(str) do
    String.split(String.trim(str), " ") |> hd()
  end

  defp maybe_cast_number(str) do
    String.to_integer(str)
  rescue
    _ -> str
  end

  defp find_key(str) do
    case find_comm(str) do
      "SET" ->
        case String.split(str, "'") do
          [_] ->
            String.split(str, " ") |> tl() |> hd()

          result ->
            tl(result)
            |> hd()
            |> String.trim()
            |> quotes()
        end

      "GET" ->
        String.split(str, " ") |> tl() |> hd() |> String.trim()
    end
  end

  defp quotes(str) do
    "\'" <> str <> "\'"
  end

  def find_value(str) do
    key = find_key(str)

    case find_comm(str) do
      "SET" ->
        str
        |> String.split(key)
        |> tl()
        |> hd()
        |> String.trim()
        |> String.replace("\\\"", "")
        |> String.replace("\"\"", "\"")
        |> find_bool()
        |> maybe_cast_number()
    end
  end

  defp find_bool(str) do
    case str do
      "TRUE" -> true
      "true" -> true
      "FALSE" -> false
      "false" -> false
      _ -> str
    end
  end
end
