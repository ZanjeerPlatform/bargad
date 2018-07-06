defmodule BargadTest do
  use ExUnit.Case
  doctest Bargad

  test "greets the world" do
    assert Bargad.hello() == :world
  end
end
