defmodule CsQueue.Mnesia.Context do
  @moduledoc """
  Contains functions for manipulation with mnesia
  """
  @table_definition [attributes: [:index, :term], type: :ordered_set, disc_copies: [Node.self()]]
  @end_of_table_atom :"$end_of_table"

  def initialize_queue_tables(name) do
    :mnesia.create_table(queue_name(name), @table_definition)
    :mnesia.create_table(waiting_queue_name(name), @table_definition)
    get_last_message_index(name)
  end

  defp get_last_message_index(name) do
    with {:atomic, keys_list} <-
           :mnesia.transaction(fn -> :mnesia.all_keys(queue_name(name)) end),
         index when not is_nil(index) <- List.last(Enum.sort(keys_list)) do
      index
    else
      {:aborted, {:no_exists, _queue}} ->
        0

      nil ->
        0
    end
  end

  def delete_queue_tables(name) do
    :mnesia.delete_table(queue_name(name))
    :mnesia.delete_table(waiting_queue_name(name))
  end

  def enqueue_message(name, index, term) do
    :mnesia.transaction(fn -> :mnesia.write({queue_name(name), index, term}) end)
  end

  def get_message_and_move_to_waiting_queue(q_name) do
    :mnesia.transaction(fn ->
      with queue <- queue_name(q_name),
           index when is_integer(index) <- :mnesia.first(queue),
           [{^queue, ^index, term}] <- :mnesia.read(queue, index),
           :ok <- :mnesia.delete({queue, index}),
           :ok <- :mnesia.write({waiting_queue_name(q_name), index, term}) do
        %{index: index, term: term}
      else
        @end_of_table_atom ->
          {:error, :no_message}
      end
    end)
    |> convert_transaction_result()
  end

  def confirm_delivery(q_name, message_index) do
    :mnesia.transaction(fn ->
      with queue <- waiting_queue_name(q_name),
           [{^queue, index, term}] <- :mnesia.read(queue, message_index),
           :ok <- :mnesia.delete({queue, index}) do
        %{index: index, term: term}
      else
        [] ->
          {:error, :no_message}
      end
    end)
    |> convert_transaction_result()
  end

  def reject_delivery(q_name, message_index, new_index) do
    :mnesia.transaction(fn ->
      with queue <- waiting_queue_name(q_name),
           [{^queue, ^message_index, term}] <- :mnesia.read(queue, message_index),
           :ok <- :mnesia.delete({queue, message_index}),
           :ok <- :mnesia.write({queue_name(q_name), new_index, term}) do
        %{index: new_index, term: term}
      else
        [] ->
          {:error, :no_message}
      end
    end)
    |> convert_transaction_result()
  end

  def get_all_queue_messages(q_name) do
    :mnesia.transaction(fn ->
      %{
        queue_messages: query_all_messages(queue_name(q_name)),
        waiting_queue: query_all_messages(waiting_queue_name(q_name))
      }
    end)
    |> convert_transaction_result()
  end

  defp query_all_messages(queue_name) do
    :mnesia.all_keys(queue_name)
    |> Enum.map(fn index ->
      [{_queue_name, _index, term}] = :mnesia.read(queue_name, index)
      term
    end)
  end

  defp queue_name(name), do: String.to_atom("#{name}_queue")
  defp waiting_queue_name(name), do: String.to_atom("#{name}_waiting_queue")
  defp convert_transaction_result({:atomic, {:error, reason}}), do: {:error, reason}
  defp convert_transaction_result({:atomic, result}), do: {:ok, result}
end
