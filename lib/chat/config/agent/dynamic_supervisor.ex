defmodule Chat.Config.Agent.DynamicSupervisor do

  use DynamicSupervisor

  def start_link(_args) do
    DynamicSupervisor.start_link(__MODULE__, nil, name: __MODULE__)
  end

  @impl true
  def init(_args), do: DynamicSupervisor.init(strategy: :one_for_one)

end
