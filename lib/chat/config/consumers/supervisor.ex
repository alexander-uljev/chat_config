defmodule Chat.Config.Consumers.Supervisor do
  use Supervisor

  def start_link(_args) do
    Supervisor.start_link(__MODULE__,
                          [name: {:global, Chat.Config.Consumers}],
                          name: __MODULE__)
  end

  @impl true

  def init(args) do
    children = [
      {Chat.Config.Consumers, args}
    ]
    Supervisor.init(children, strategy: :one_for_one)
  end
end
