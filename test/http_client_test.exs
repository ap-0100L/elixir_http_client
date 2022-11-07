defmodule HttpClientTest do
  use ExUnit.Case
  doctest HttpClient

  test "greets the pong" do
    assert HttpClient.ping() == :pong
  end
end
