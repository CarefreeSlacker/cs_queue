defmodule CsQueue.Api.ConsumerApi do
  @moduledoc """
  Contains functions for receiving messages from queue. And acknowledge for delivery or reject.
  """
  alias CsQueue.Queue.QueueManager

  @spec get_message_from_queue(binary) ::
          {:ok, %{index: integer, term: term}}
          | {:error, :no_message}
          | {:error, :no_queue}
          | {:error, :please_repeat_later}
  defdelegate get_message_from_queue(queue_name), to: QueueManager

  @spec confirm_message_delivery(binary, integer, boolean) ::
          :ok
          | {:ok, %{index: integer, term: term}}
          | {:error, :no_message}
          | {:error, :no_queue}
          | {:error, :please_repeat_later}
  defdelegate confirm_message_delivery(queue_name, message_id, waiting_queue \\ false),
    to: QueueManager

  @spec reject_message_delivery(binary, integer) ::
          :ok
          | {:ok, %{index: integer, term: term}}
          | {:error, :no_message}
          | {:error, :no_queue}
          | {:error, :please_repeat_later}
  defdelegate reject_message_delivery(queue_name, message_id, waiting_queue \\ false),
    to: QueueManager
end
