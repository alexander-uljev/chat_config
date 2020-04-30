defmodule Chat.Config.Store.Supervisor do

  @parent \
    Module.split(__MODULE__)
    |> Enum.take(3)
    |> Module.concat()

  use Supervisor

  def start_link(_args) do
    Supervisor.start_link(__MODULE__,
                          [name: {:global, @parent}],
                          name: __MODULE__)
  end

  @impl true

  def init(opts) do
    children = [
      {@parent, opts}
    ]
    Supervisor.init(children, strategy: :one_for_one)
  end
end
