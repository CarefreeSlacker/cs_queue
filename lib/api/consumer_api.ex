defmodule CsQueue.Api.ConsumerApi do
  @moduledoc """
  Contains functions for receiving messages from queue. And acknowledge for delivery or reject.
  """
  alias CsQueue.Queue.QueueManager

  @doc """
  Gets message from given queue those looks like `{:ok, %{index: integer, term: any}}`.
  Where `index` is order number of message. Could be used to confirm or reject message delivery.
  Term - message itself. Could have any format.

  Or return error those looks like `{:error, reason}`. Reason could be:
  * :no_message - there is no messages in queue.
  * :no_queue - no queue with given name.
  * :please_repeat_later - worker is not loaded currently. Consumer must repeat it soon.
  """
  @spec get_message_from_queue(binary) ::
          {:ok, %{index: integer, term: term}}
          | {:error, :no_message}
          | {:error, :no_queue}
          | {:error, :please_repeat_later}
  defdelegate get_message_from_queue(queue_name), to: QueueManager

  @doc """
  Confirm message delivery. Remove message from waiting for confirmation queue.
  First argument is queue name, `binary`.
  Second argument is message_index `index` could be received when you get message by `get_message_from_queue/3`.

  Third arguent tells are you waiting for queue result, `boolean`. `false` by default.
  If third argument is `true` and message with given `message_index` exists,
  returns `{:ok, %{index: integer, term: term}}`.
  Where `index` is order number of message.
  Term - message itself. Could have any format.
  If third argument is `false` and message with given `message_index` exists returns `:ok`

  Or return error those looks like `{:error, reason}`. Reason could be:
  * :no_message - there is no message with given message_index.
  * :no_queue - no queue with given name.
  * :please_repeat_later - worker is not loaded currently. Consumer must repeat it soon.
  """
  @spec confirm_message_delivery(binary, integer, boolean) ::
          :ok
          | {:ok, %{index: integer, term: term}}
          | {:error, :no_message}
          | {:error, :no_queue}
          | {:error, :please_repeat_later}
  defdelegate confirm_message_delivery(queue_name, message_index, waiting_queue \\ false),
    to: QueueManager

  @doc """
  Reject message delivery. Move message back to the end of the queue and set it new `index`.
  First argument is queue name, `binary`.
  Second argument is message_index `index` could be received when you get message by `get_message_from_queue/3`.

  Third arguent tells are you waiting for queue result, `boolean`. `false` by default.
  If third argument is `true` and message with given `message_index` exists,
  returns `{:ok, %{index: integer, term: term}}`.
  Where `index` is order number of message.
  Term - message itself. Could have any format.
  If third argument is `false` and message with given `message_index` exists returns `:ok`

  Or return error those looks like `{:error, reason}`. Reason could be:
  * :no_message - there is no message with given message_index.
  * :no_queue - no queue with given name.
  * :please_repeat_later - worker is not loaded currently. Consumer must repeat it soon.
  """
  @spec reject_message_delivery(binary, integer) ::
          :ok
          | {:ok, %{index: integer, term: term}}
          | {:error, :no_message}
          | {:error, :no_queue}
          | {:error, :please_repeat_later}
  defdelegate reject_message_delivery(queue_name, message_index, waiting_queue \\ false),
    to: QueueManager
end
