defmodule Chat.Config do
  @moduledoc """
  Root for :chat_config application.

  It gives an opportunity to start  configuration agents which can update
  applications' configuration on the fly. User is completely responsible for the
  results of this application work. Before an update configuration must be stored
  in Store module and agent must be registered as a consumer in Consumers module
  .
  """

  alias Chat.Config.{Consumers, Store}

  @doc """
  Pushes all the configs stored in Config.Store to all the Agent stored in
  Consumers.

  Completely irresponsible. Checks nothing, always returns :ok.
  """
  @spec push_update() :: :ok

  def push_update() do
    config = Store.fetch()
    Consumers.fetch()
    |> Enum.each(fn {app, agent} ->
      send(agent, {:update_config, config[app]})
    end)
  end

end
