defmodule Chat.ConfigTest do
  use ExUnit.Case
  alias Chat.Config
  alias Chat.Config.{Consumers, Agent, Store}

  setup_all :clear_state
  setup :create_context

  test "pushes updates to consumers", %{agent: agent, app: app} do
    Consumers.put({app, agent})
    Store.put(%{app => %{par: "val"}})
    old_val = Application.get_env(app, :par)
    Config.push_update()
    Process.sleep 10
    new_val = Application.get_env(app, :par)
    assert old_val != new_val
    assert new_val == "val"
    Application.delete_env(app, :par)
  end

  def clear_state(_) do
    Application.delete_env(:chat_config, :par)
    Config.Store.clear()
    Config.Consumers.clear()
  end

  defp create_context(_) do
    app = :chat_config
    {:ok, pid} =
      DynamicSupervisor.start_child(Agent.DynamicSupervisor, {Agent, {app, []}})
    %{agent: pid, app: app}
  end

end
