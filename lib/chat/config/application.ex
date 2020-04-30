defmodule Chat.Config.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      Chat.Config.Store.Supervisor,
      Chat.Config.Consumers.Supervisor,
      Chat.Config.Agent.DynamicSupervisor]
    opts = [strategy: :one_for_one, name: Chat.Config.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
