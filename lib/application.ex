defmodule CsQueue.Application do
  @moduledoc false

  use Application
  alias CsQueue.Queue.Supervisor, as: QSupervisor
  alias CsQueue.Mnesia.MnesiaRepo

  def start(_type, _args) do
    children = [
      {QSupervisor, [name: QSupervisor]},
      {MnesiaRepo, []}
    ]

    opts = [strategy: :one_for_one, name: CsQueue.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
