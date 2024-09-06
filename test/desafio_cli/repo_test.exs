defmodule DesafioCli.RepoTest do
  use ExUnit.Case, async: false

  alias DesafioCli.Repo

  setup do
    {:ok, table} = Repo.init_table()

    # on_exit(fn ->
    #   :dets.delete_all_objects(table)
    # end)

    {:ok, table: table}
  end

  describe "set/3" do
    test "returns FALSE and a value when first set", %{table: table} do
      assert Repo.upsert(table, :test1, 1) == {false, :test1, 1}
      assert :dets.delete_all_objects(table)
    end

    test "returns TRUE and a value when already set", %{table: table} do
      Repo.upsert(table, :test, 2)
      assert Repo.upsert(table, :test, 3) == {true, :test, 3}
      assert :dets.delete_all_objects(table)
    end
  end

  describe "get/2" do
    test "returns value when existing value", %{table: table} do
      value = 5
      Repo.upsert(table, :outro, value)

      assert Repo.select(table, :outro) == value
    end

    test "returns nil when no key found", %{table: table} do
      assert Repo.select(table, :vazio) == nil
    end
  end
end
