defmodule CsQueue.Api.ProducerApi do
  @moduledoc """
  Contains functions for manipulating queues and enqueuing messages to queues.
  """
  alias CsQueue.Queue.QueueManager
  alias CsQueue.Queue.Supervisor, as: QSupervisor

  @spec initialize_queue(binary) :: :ok | {:error, :allready_exist}
  def initialize_queue(queue_name) do
    QSupervisor.start_child(%{name: queue_name})
  end

  @spec terminate_queue(binary, boolean) ::
          :ok
          | {:error, :no_queue}
          | {:ok, %{queue_messages: list(any), waiting_queue: list(any)}}
  def terminate_queue(queue_name, return_queue_result \\ false) do
    QSupervisor.terminate_child(queue_name, return_queue_result)
  end

  @spec enqueue_message(binary, any) :: :ok | {:error, :no_queue} | {:error, :please_repeat}
  def enqueue_message(queue_name, term) do
    QSupervisor.enqueue_message(queue_name, term)
  end
end
