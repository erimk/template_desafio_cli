defmodule DesafioCli.Utils do
  def to_atom(str) do
    String.to_existing_atom(str)
  rescue
    _ -> String.to_atom(str)
  end
end
