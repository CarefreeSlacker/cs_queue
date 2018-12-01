defmodule CsQueue.Api.ConsumerApi do
  @moduledoc """
  Contains functions for receiving messages from queue. And acknowledge for delivery or reject.
  """
  alias CsQueue.Queue.QueueManager

  @spec get_message_from_queue(binary) ::
          {:ok, term} | {:error, :no_message} | {:error, :no_queue}
  def get_message_from_queue(queue_name) do
  end

  @spec confirm_message_delivery(binary, integer, boolean) ::
          :ok | {:error, :no_message} | {:error, :no_queue}
  def confirm_message_delivery(queue_name, message_id, waiting_queue \\ false) do
  end

  @spec reject_message_delivery(binary, integer) ::
          :ok | {:error, :no_message} | {:error, :no_queue}
  def reject_message_delivery(queue_name, message_id, waiting_queue \\ false) do
  end
end
