defmodule CachexSampleTest do
  use ExUnit.Case
  doctest CachexSample

  test "greets the world" do
    assert CachexSample.hello() == :world
  end
end
