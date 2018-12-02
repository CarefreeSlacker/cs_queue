defmodule CsQueue.Api.ProducerApi do
  @moduledoc """
  Contains functions for manipulating queues and enqueuing messages to queues.
  """
  alias CsQueue.Queue.Supervisor, as: QSupervisor

  @doc"""
  Initialize queue with given name. And return `:ok` if everything allright.
  Or return `{:error, :allready_exist}` Nuff Said.
  """
  @spec initialize_queue(binary) :: :ok | {:error, :allready_exist}
  defdelegate initialize_queue(queue_name), to: QSupervisor, as: :start_child

  @doc"""
  Terminate queue with given name.
  First argument is queue name.
  Second argument tells do you need to receive all queued messages, `boolean`. `false` by default.
  If second argument `false` and given queue exists - returns `:ok`
  If second arument `true` and given queue exists - returns {:ok, %{queue_messages: list(any), waiting_queue: list(any)}}
  Or return error `{:error, :no_queue}` if no queue with given name.
  """
  @spec terminate_queue(binary, boolean) ::
          :ok
          | {:error, :no_queue}
          | {:ok, %{queue_messages: list(any), waiting_queue: list(any)}}
  defdelegate terminate_queue(queue_name, return_queue_result \\ false),
    to: QSupervisor,
    as: :terminate_child

  @doc"""
  Enqueue message to the end of the queue and return `:ok` if everything allright.
  Or return error those looks like `{:error, reason}`
  Where `reason` could be:
  * :no_queue - no queue with given name
  * :please_repeat_later - worker is not loaded currently. Consumer must repeat it soon.
  """
  @spec enqueue_message(binary, any) :: :ok | {:error, :no_queue} | {:error, :please_repeat_later}
  defdelegate enqueue_message(queue_name, term), to: QSupervisor, as: :enqueue_message
end
