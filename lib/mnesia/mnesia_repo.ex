defmodule CsQueue.Mnesia.MnesiaRepo do
  @moduledoc """
  Start mnesia. Initialize schema if it does not exist.
  """
  use GenServer

  alias CsQueue.Queue.Supervisor, as: QSupervisor

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_opts) do
    initialize_mnesia()
    start_table_workers()
    {:ok, %{}}
  end

  defp initialize_mnesia do
    :mnesia.start()
    # TODO implement creation of directory_name
    # and reseting database function
  end

  defp start_table_workers do
    :mnesia.system_info(:tables)
    |> Enum.map(&Atom.to_string(&1))
    |> Enum.each(fn table_name ->
      case Regex.run(~r/(\w+)_waiting_queue/, table_name) do
        nil -> :ok
        [_partial_match] -> :ok
        [_full_match, queue_name] -> QSupervisor.start_child(%{name: queue_name})
      end
    end)
  end
end
