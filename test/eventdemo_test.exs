defmodule EventdemoTest do
  use ExUnit.Case
  doctest Eventdemo

  test "test start up" do
    assert Eventdemo.hello() == :world
  end

  test "test valid json" do
    
  end
end
