defmodule KensakukunTest do
  use ExUnit.Case
  doctest Kensakukun

  test "greets the world" do
    assert Kensakukun.hello() == :world
  end
end
