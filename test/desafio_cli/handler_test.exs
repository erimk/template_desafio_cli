defmodule DesafioCli.HandlerTest do
  use ExUnit.Case, async: false

  import ExUnit.CaptureIO

  alias DesafioCli.Handler
  alias DesafioCli.Repo

  setup do
    {:ok, table} = Repo.init_table()

    {:ok, table: table}
  end

  describe "set/2" do
    test "returns sucessfully when valid data", %{table: table} do
      command = ["SET", "chave", 5]

      subject = capture_io(fn -> Handler.set(table, command) end)

      assert subject =~ "FALSE 5"
      assert :dets.delete_all_objects(table)
    end

    test "returns ok when valid data reinput", %{table: table} do
      key = "key"
      Repo.upsert(table, key, 1)
      command = ["SET", key, 9]

      subject = capture_io(fn -> Handler.set(table, command) end)

      assert subject =~ "TRUE 9"
      assert :dets.delete_all_objects(table)
    end
  end

  describe "get/2" do
    test "returns value when request existing data", %{table: table} do
      key = "chav"
      value = 8
      Repo.upsert(table, key, 8)
      command = ["GET", key]

      subject = capture_io(fn -> Handler.get(table, command) end)

      assert subject =~ "#{value}"
      assert :dets.delete_all_objects(table)
    end

    test "returns nil when request non existing data", %{table: table} do
      command = ["GET", "random"]

      subject = capture_io(fn -> Handler.get(table, command) end)

      assert subject =~ "NIL"
      assert :dets.delete_all_objects(table)
    end

    test "returns syntax error", %{table: table} do
      command = ["GET"]

      subject = capture_io(fn -> Handler.get(table, command) end)

      assert subject =~ """
             ERR \"GET <chave> - Syntax error\"
             """

      assert :dets.delete_all_objects(table)
    end
  end

  describe "begin/1" do
    test "returns transactions number", %{table: table} do
      subject =
        capture_io(fn ->
          table
          |> Handler.begin()
          |> Handler.begin()
        end)

      assert subject =~ "1"
      assert subject =~ "2"
      assert :dets.delete_all_objects(table)
    end
  end

  describe "rollback/1" do
    test "returns valid data after rollback", %{table: table} do
      subject =
        capture_io(fn ->
          table
          |> Handler.get(["GET", "teste"])
          |> Handler.begin()
          |> Handler.set(["SET", "teste", 1])
          |> Handler.get(["GET", "teste"])
          |> Handler.rollback()
          |> Handler.get(["GET", "teste"])
        end)

      assert subject =~ "NIL\n1\nFALSE 1\n1\n0\nNIL\n"
      assert :dets.delete_all_objects(table)
    end

    test "returns valid data with recursive rollback", %{table: table} do
      subject =
        capture_io(fn ->
          table
          |> Handler.get(["GET", "teste"])
          |> Handler.begin()
          |> Handler.set(["SET", "teste", 1])
          |> Handler.get(["GET", "teste"])
          |> Handler.begin()
          |> Handler.set(["SET", "foo", "bar"])
          |> Handler.set(["SET", "bar", "baz"])
          |> Handler.get(["GET", "foo"])
          |> Handler.get(["GET", "bar"])
          |> Handler.rollback()
          |> Handler.get(["GET", "foo"])
          |> Handler.get(["GET", "bar"])
          |> Handler.get(["GET", "teste"])
        end)

      assert subject =~ """
             NIL
             1
             FALSE 1
             1
             2
             FALSE bar
             FALSE baz
             bar
             baz
             1
             NIL
             NIL
             1
             """

      assert :dets.delete_all_objects(table)
    end
  end

  describe "commit/1" do
    test "returns valid data with commit", %{table: table} do
      subject =
        capture_io(fn ->
          table
          |> Handler.get(["GET", "teste"])
          |> Handler.begin()
          |> Handler.set(["SET", "teste", 1])
          |> Handler.get(["GET", "teste"])
          |> Handler.commit()
          |> Handler.get(["GET", "teste"])
        end)

      assert subject =~ "NIL\n1\nFALSE 1\n1\n0\n1\n"
      assert :dets.delete_all_objects(table)
    end

    test "returns valid data with recursive commit", %{table: table} do
      subject =
        capture_io(fn ->
          table
          |> Handler.get(["GET", "teste"])
          |> Handler.begin()
          |> Handler.set(["SET", "teste", 1])
          |> Handler.get(["GET", "teste"])
          |> Handler.begin()
          |> Handler.set(["SET", "foo", "bar"])
          |> Handler.set(["SET", "bar", "baz"])
          |> Handler.get(["GET", "foo"])
          |> Handler.get(["GET", "bar"])
          |> Handler.commit()
          |> Handler.get(["GET", "foo"])
          |> Handler.get(["GET", "bar"])
          |> Handler.get(["GET", "teste"])
          |> Handler.rollback()
          |> Handler.get(["GET", "teste"])
          |> Handler.get(["GET", "foo"])
          |> Handler.get(["GET", "bar"])
        end)

      assert subject =~
               """
               NIL
               1
               FALSE 1
               1
               2
               FALSE bar
               FALSE baz
               bar
               baz
               1
               bar
               baz
               1
               0
               NIL
               NIL
               NIL
               """

      assert :dets.delete_all_objects(table)
    end

    test "returns error without begin", %{table: table} do
      subject =
        capture_io(fn ->
          table
          |> Handler.rollback()
        end)

      assert subject =~ "No transaction open to rollback."
      assert :dets.delete_all_objects(table)
    end
  end

  describe "fallback/2" do
    test "returns erro message when fallback", %{table: table} do
      command = ["TRY"]

      subject =
        capture_io(fn ->
          table
          |> Handler.fallback(command)
        end)

      assert subject =~ """
             ERR \"No command TRY\"
             """

      assert :dets.delete_all_objects(table)
    end

    test "returns erro message when no command found", %{table: table} do
      command = [""]

      subject =
        capture_io(fn ->
          table
          |> Handler.fallback(command)
        end)

      assert subject =~ """
             ERR \"No command found.\"
             """

      assert :dets.delete_all_objects(table)
    end
  end

  describe "clean/1" do
    test "returns ok when clean data", %{table: table} do
      key = "key"
      value = 7
      Repo.upsert(table, key, value)

      subject =
        capture_io(fn ->
          table
          |> Handler.get(["GET", key])
          |> Handler.clean()
          |> Handler.get(["GET", key])
        end)

      assert subject =~ """
             #{value}
             NIL
             """

      assert :dets.delete_all_objects(table)
    end
  end
end
