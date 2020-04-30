defmodule Chat.Config.Agent do
  @moduledoc """
  An agent that holds environment data, receives configuration updates and
  executes them.

  Please note that it needs {app_name, opts} argument to start a link.
  """

  use GenServer

  @doc """
  Starts a link through `GenServer.start_link/3`.

  Requires {app_name, opts} as argument. opts are `GenServer.options()` so it
  features all the flexibility that GenServer does.
  """
  @spec start_link({app :: atom(), opts :: GenServer.options()})
   :: GenServer.on_start()

  def start_link({app, opts}) do
    GenServer.start_link(__MODULE__, app, opts)
  end

  @doc """
  Simply returns current application's environment.
  """
  @spec app_env(agent :: pid()) :: keyword()

  def app_env(agent) when is_pid(agent) do
    GenServer.call(agent, :env)
  end

  @doc """
  Returns an application name that this agent is working for.
  """
  @spec application(agent :: pid()) :: atom()

  def application(agent) do
    GenServer.call(agent, :app)
  end

  @impl true
  @spec init(app :: Application.app()) :: {:ok, Application.app()}
  def init(app), do: {:ok, app}

  @impl true
  def handle_call(:env, _caller, app) do
    {:reply, Application.get_all_env(app), app}
  end

  @impl true
  def handle_call(:app, _caller, app), do: {:reply, app, app}

  @impl true
  def handle_info({:update_config, config}, app) do
    :ok = update_config(app, config)
    {:noreply, app}
  end

  defp update_config(application, %{} = param) do
    Enum.each(param, fn {key, value} ->
      Application.put_env(application, key, value)
    end)
  end

end
