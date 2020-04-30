defmodule Chat.Config.StoreTest do
  use ExUnit.Case
  alias Chat.Config.Store

  setup_all :cleanup
  setup :clear_config

  test "returns stored configuration" do
    assert Store.fetch() == %{}
  end

  test "stores configuration key and value" do
    Store.put(%{app0: %{par1: "val1"}})
    assert Store.fetch() == %{app0: %{par1: "val1"}}
  end

  test "stores a complete configuration" do
    Store.put(%{app0: %{par1: "val1"}})
    Store.put(%{app0: %{par1: "val111", par2: "val2"}})
    assert Store.fetch() == %{app0: %{par1: "val111", par2: "val2"}}
  end

  test "clears configuration" do
    Store.put(%{app0: %{par1: "val1", par2: "val2"}})
    Store.clear()
    assert Store.fetch() == %{}
  end

  defp cleanup(_) do
    on_exit(fn -> Application.delete_env(:chat_config, :par) end)
  end

  defp clear_config(_) do
    :ok = Store.clear()
  end

end
