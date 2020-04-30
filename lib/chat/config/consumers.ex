defmodule Chat.Config.Consumers do
  @moduledoc """
  A simple storage that holds agents' destination data.

  May seem redundant but it does all the neccesary checks to ensure that there
  are no duplicates stored and agents' data is a valid destination type. It is
  starterd by it's supervisor with a registered name of this module. The valid
  format is "atom => Process.dest". Please match on :ok to be sure you provide
  valid data.
  """

  @type not_consumer_error    :: {:error, :not_consumer}
  @type not_destination_error :: {:error, :not_destination}

  @consumer {:global, __MODULE__}

  use Agent

  @doc """
  Starts a link through `Agent.start_link/2`.

  Returns {:ok, pid} or Agent's error tuples.
  """
  @spec start_link(opts :: keyword()) :: Agent.on_start()

  def start_link(opts) do
    Agent.start_link(fn() -> %{} end, opts)
  end

  @doc """
  Rerturns an entire consumers list.
  """
  @spec fetch() :: %{optional(atom()) => Process.dest()}

  def fetch() do
    Agent.get(@consumer, &(Map.to_list(&1)))
  end

  @doc """
  Returns specified app's configuration updates consumers or nil.
  """
  @spec fetch(app :: atom()) :: %{required(atom()) => Process.dest()} | nil

  def fetch(app) do
    Agent.get(@consumer, &(Map.to_list(&1[app])))
  end

  @doc """
  Stores a consumer. Consumer must be an {app, agent} tuple.
  """
  @spec put({app :: atom(), agent :: Process.dest()})
  :: :ok | not_destination_error()

  def put({app, agent}) when is_atom(app) do
    if is_destination?(agent) do
      Agent.update(@consumer, &(Map.put(&1, app, agent)))
    else
      not_destination_error()
    end
  end

  @doc """
  Stores a list of consumers. Consumer must be an *{app, agent}* tuple.
  """
  @spec put(consumers :: [{atom(), Process.dest()}])
  :: :ok | not_destination_error()

  def put_list(consumers) when is_list(consumers) do
    if Enum.all?(consumers, &(is_consumer?(&1))) do
      consumers = Enum.into(consumers, %{})
      Agent.update(@consumer, &(Map.merge(&1, consumers)))
    else
      not_consumer_error()
    end
  end

  @doc """
  Deletes consumer of app configuration updates.

  Returns :ok if there is such an app in the store or *{:error, :not_found}*.
  """
  @spec delete(app :: atom) :: :ok | {:error, :not_found}

  def delete(app) when is_atom(app) do
    Agent.get_and_update(@consumer, fn (consumers) ->
      if Map.has_key?(consumers, app),
      do:   {:ok, Map.delete(consumers, app)},
      else: {{:error, :not_found}, consumers}
    end)
  end

  @doc """
  Simply clears internal storage.
  """
  @spec clear() :: :ok
  def clear() do
    Agent.update(@consumer, fn(_list) -> %{} end)
  end

  # private

  @spec is_consumer?(term()) :: boolean()
  defp is_consumer?(consumer) do
    try do
      {app, agent} = consumer
      is_atom(app) and is_destination?(agent)
    rescue
      MatchError -> false
    end
  end

  @doc """
  Checks if `agent` is a sendable term.
  """
  @spec is_destination?(term()) :: boolean()

  def is_destination?(agent) do
    is_pid(agent)
    or agent in :erlang.registered()
    or agent in :global.registered_names()
    or is_port(agent)
  end

  @spec not_destination_error() :: {:error, :not_destination}
  defp not_destination_error() do
    {:error, :not_destination}
  end

  @spec not_consumer_error() :: {:error, :not_consumer}
  defp not_consumer_error() do
    {:error, :not_consumer}
  end

end
