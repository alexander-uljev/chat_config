# defmodule MockConsumer do
#
#   def start_link(_opts) do
#     spawn_link(fn -> run(%{}) end)
#   end
#
#   @impl true
#   def update_config(%{} = value) do
#     Enum.each(value, fn {key, value} ->
#       :application.get_application()
#       |> Application.put_env(key, value)
#     end)
#   end
#
#   defp run(config) do
#     run(
#       loop(config)
#     )
#   end
#
#   defp loop(config) do
#     receive do
#       {:update_config, value} -> update_config(value)
#       config
#     end
#   end
#
# end

System.put_env("MIX_ENV", "test")
ExUnit.start()
