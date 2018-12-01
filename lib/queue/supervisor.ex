defmodule CsQueue.Queue.Supervisor do
  @moduledoc false

  use DynamicSupervisor

  alias CsQueue.Queue.QueueManager

  def start_link(arg) do
    DynamicSupervisor.start_link(__MODULE__, arg, name: __MODULE__)
  end

  def start_child(%{} = args) do
    child = {QueueManager, args}

    case DynamicSupervisor.start_child(__MODULE__, child) do
      {:ok, _pid} -> :ok
      {:error, {:already_started, _pid}} -> {:error, :already_exist}
    end
  end

  def terminate_child(queue_name, return_queue_result) do
    with pid when not is_nil(pid) <- QueueManager.check_if_queue_exist(queue_name),
         result <- terminate_and_return_result(pid, return_queue_result) do
      result
    else
      nil -> {:error, :no_queue}
    end
  end

  def enqueue_message(queue_name, term) do
    case QueueManager.check_if_queue_exist(queue_name) do
      nil -> {:error, :no_queue}
      pid -> QueueManager.enqueue_message(pid, term)
    end
  end

  defp terminate_and_return_result(pid, false) do
    QueueManager.remove_queues(pid)
    DynamicSupervisor.terminate_child(__MODULE__, pid)
    :ok
  end

  defp terminate_and_return_result(pid, true) do
    queue_messages = QueueManager.get_queue_messages(pid)

    {
      terminate_and_return_result(pid, false),
      queue_messages
    }
  end

  def init(_opts) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end
end
