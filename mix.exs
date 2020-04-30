defmodule Chat.Config.MixProject do
  use Mix.Project

  def project do
    [
      app: :chat_config,
      version: "0.1.0",
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      build_path: "../../_build"
    ]
  end

  def application do
    [
      registered: [
        Chat.Config.Supervisor,
        Chat.Config.Agent.DynamicSupervisor,
        Chat.Config.Consumer,
        Chat.Config.Consumer.Supervisor,
        Chat.Config.Host,
        Chat.Config.Host.Supervisor
      ],
      extra_applications: [:logger],
      mod: {Chat.Config.Application, []}
    ]
  end

  defp deps do
    []
  end
end
