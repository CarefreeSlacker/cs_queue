defmodule CsQueue.Api.ProducerApi do
  @moduledoc """
  Contains functions for manipulating queues and enqueuing messages to queues.
  """
  alias CsQueue.Queue.Supervisor, as: QSupervisor

  @spec initialize_queue(binary) :: :ok | {:error, :allready_exist}
  defdelegate initialize_queue(queue_name), to: QSupervisor, as: :start_child

  @spec terminate_queue(binary, boolean) ::
          :ok
          | {:error, :no_queue}
          | {:ok, %{queue_messages: list(any), waiting_queue: list(any)}}
  defdelegate terminate_queue(queue_name, return_queue_result \\ false),
    to: QSupervisor,
    as: :terminate_child

  @spec enqueue_message(binary, any) :: :ok | {:error, :no_queue} | {:error, :please_repeat_later}
  defdelegate enqueue_message(queue_name, term), to: QSupervisor, as: :enqueue_message
end
