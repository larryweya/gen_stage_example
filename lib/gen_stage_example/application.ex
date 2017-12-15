defmodule GenStageExample.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    # List all child processes to be supervised
    children = [
      # Starts a worker by calling: GenStageExample.Worker.start_link(arg)
      # {GenStageExample.Worker, arg},
      Supervisor.Spec.worker(GenStageExample.Store, [[]]),
      Supervisor.Spec.worker(GenStageExample.Producer, []),
      Supervisor.Spec.worker(GenStageExample.Consumer, [], id: :consumer1),
      Supervisor.Spec.worker(GenStageExample.Consumer, [], id: :consumer2),
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: GenStageExample.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
