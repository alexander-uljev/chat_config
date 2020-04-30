defmodule Chat.Config.AgentTest do
  use ExUnit.Case
  alias Chat.Config
  alias Chat.Config.Agent

  setup_all :start_link
  setup     :clean_state

  test "returns app name and env" do
    {:ok, agent} = Agent.start_link({:chat_config, []})
    assert Agent.app_env(agent)     == []
    assert Agent.application(agent) == :chat_config
  end

  test "updates internal configuration on :update_config message",
  %{agent: agent} do
    ini_conf = Agent.app_env(agent)
    send(agent, {:update_config, %{par: "val"}})
    upd_conf = Agent.app_env(agent)
    assert ini_conf != upd_conf
    assert upd_conf == [par: "val"]
  end

  def clean_state(_) do
    Application.delete_env(:chat_config, :par)
    Config.Store.clear()
    Config.Consumers.clear()
  end

  defp start_link(_) do
    {:ok, pid} = Agent.start_link({:chat_config, []})
    %{agent: pid}
  end

end
