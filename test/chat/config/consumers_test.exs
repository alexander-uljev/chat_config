defmodule Chat.Config.ConsumersTest do
  use ExUnit.Case
  alias Chat.Config.Consumers

  setup :clear_consumer

  test "lists consumer id" do
    assert Consumers.fetch() == []
  end

  test "stores consumer id" do
    :ok = Consumers.put({:chat_config, self()})
    assert Consumers.fetch() == [chat_config: self()]
  end

  test "stores consumer id with no duplicates" do
    Consumers.put({:chat_config, self()})
    Consumers.put({:chat_config, self()})
    assert Consumers.fetch() == [chat_config: self()]
  end

  test "stores consumer id list" do
    consumers = Enum.map([:app0, :app1, :app2], &({&1, self()}))
    Consumers.put_list(consumers)
    assert Consumers.fetch() == [app0: self(), app1: self(), app2: self()]
  end

  test "stores consumer id list with no duplicates" do
    pids = [{:app2, self()},{:app0, self()},{:app1, self()}]
    Consumers.put_list(pids)
    assert Consumers.fetch() == [app0: self(), app1: self(), app2: self()]
  end

  test "deletes consumer from a list" do
    consumers = Enum.map([:app0, :app1, :app2],
      &({&1, spawn_link(fn -> nil end)}))
    :ok = Consumers.put_list(consumers)
    :ok = Consumers.delete(:app0)
    assert {:error, :not_found} == Consumers.delete(:app0)
  end

  test "clears consumer list" do
    consumers = Enum.map([:app0, :app1, :app2],
      &({&1, spawn_link(fn -> nil end)}))
    Consumers.put_list(consumers)
    Consumers.clear()
    assert Consumers.fetch() == []
  end

  defp clear_consumer(_) do
    :ok = Consumers.clear(); %{}
  end

end
