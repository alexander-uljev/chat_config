defmodule Chat.Config.Store do
  @moduledoc """
  Simple storage for configuration data.

  It's supervisor starts it with a registered name of it's module. All data
  stored must be in a "atom => %{key => value}" format, otherwise an error will
  be raised. Since it's started with a globally registered name, extreme care
  must be taken while working with it. Please note that it's not the entire
  application's configuration to be stored here and it won't get fetched
  automatically, no initialization will happen by itself. It's a configuration
  changes storage that are to be pushed to configuration agents.
  """

  @store {:global, __MODULE__}

  use Agent

  @doc """
  Forwards opts to `Agent.start_link/2`.

  Returns {:ok, pid} or Agent's error tuples.
  """
  @spec start_link(opts :: keyword()) :: Agent.on_start()

  def start_link(opts) do
    Agent.start_link(fn() -> %{} end, opts)
  end

  @doc """
  Returns entire stored map of applications configurations.
  """
  @spec fetch() :: map()

  def fetch() do
    Agent.get(@store, fn(state) -> state end)
  end

  @doc """
  Returns passed app's configuration.
  """
  @spec fetch(app :: atom()) :: map()

  def fetch(app) when is_atom(app) do
    Agent.get(@store, fn(state) -> state[app] end)
  end

  @doc """
  Stores a config under app key.

  *config* must be a map that can be used by `Application.put_env/2`.
  """
  @spec put(app :: atom(), config :: map()) :: :ok

  def put(app, config) when is_atom(app) and is_map(config) do
    Agent.update(@store, fn(state) -> Map.put(state, app, config) end)
  end

  @doc """
  Merges passed config into existing one.

  config must be a map that can be used by `Application.put_env/2`.
  """
  @spec put(env :: map()) :: :ok

  def put(env) when is_map(env) do
    if Enum.all?(env, &(valid_env?(&1))) do
      Agent.update(@store, fn(state) -> Map.merge(state, env) end)
    else
      {:error, :invalid_argument}
    end
  end

  @doc """
  Removes specified application's configuration from the storage.
  """
  @spec remove(app :: atom()) :: :ok

  def remove(app) when is_atom(app) do
    Agent.update(@store, fn(state) -> Map.delete(state, app) end)
  end

  @doc """
  Clears the storrage from all the data.
  """
  @spec clear() :: :ok
  def clear() do
    Agent.update(@store, fn(_state) -> %{} end)
  end

  # private

  defp valid_env?(env) do
    try do
      {par, _val} = env
      is_atom(par)
    rescue
      MatchError -> false
    end
  end

end
