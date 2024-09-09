defmodule DesafioCli.UtilsTest do
  use ExUnit.Case

  alias DesafioCli.Utils

  describe "get_command/1" do
    test "returns ok when value is phrase" do
      str = "SET chv \"uma string com espaços\"\n"
      assert Utils.get_command(str) == ["SET", "chv", "\"uma string com espaços\""]
    end

    test "returns ok when simple key" do
      str = "SET outro \"\\\"teste\\\"\"\n"
      assert Utils.get_command(str) == ["SET", "outro", "\"teste\""]
    end

    test "returns ok when key with single quotes" do
      str = "SET 'outra coisa' \"\\\"teste 1\\\"\"\n"
      assert Utils.get_command(str) == ["SET", "'outra coisa'", "\"teste 1\""]
    end

    test "returns ok when digit mixed" do
      str = "SET key a10\n"
      assert Utils.get_command(str) == ["SET", "key", "a10"]
    end

    test "returns ok when space digit mixed" do
      str = "SET key \"ola 1\"\n"
      assert Utils.get_command(str) == ["SET", "key", "\"ola 1\""]
    end

    test "returns ok when digit" do
      str = "SET key 101\n"
      assert Utils.get_command(str) == ["SET", "key", 101]
    end

    test "returns ok when bool 1" do
      str = "SET key true\n"
      assert Utils.get_command(str) == ["SET", "key", true]
    end

    test "returns ok when bool 2" do
      str = "SET key TRUE\n"
      assert Utils.get_command(str) == ["SET", "key", true]
    end

    test "returns ok when bool 3" do
      str = "SET key FALSE\n"
      assert Utils.get_command(str) == ["SET", "key", false]
    end

    test "returns ok when bool 4" do
      str = "SET key false\n"
      assert Utils.get_command(str) == ["SET", "key", false]
    end

    test "set" do
      command = "SET 'outra coisa' \"\\\"teste 1\\\"\"\n"
      assert Utils.get_command(command) == ["SET", "'outra coisa'", "\"teste 1\""]
    end

    test "get" do
      command = "GET key\n"
      assert Utils.get_command(command) == ["GET", "key"]
    end

    test "begin" do
      command = "BEGIN\n"
      assert Utils.get_command(command) == ["BEGIN"]
    end

    test "commit" do
      command = "COMMIT  \n"
      assert Utils.get_command(command) == ["COMMIT"]
    end

    test "rollback" do
      command = "ROLLBACK \n"
      assert Utils.get_command(command) == ["ROLLBACK"]
    end
  end
end
