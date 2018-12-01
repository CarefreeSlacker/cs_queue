defmodule CsQueue.Mnesia.Context do
  @defmodule """
  Contains functions for manipulation with mnesia
  """
  @table_definition [attributes: [:index, :term], type: :ordered_set, disc_copies: [Node.self()]]

  def initialize_queue_tables(name) do
    :mnesia.create_table(queue_name(name), @table_definition)
    :mnesia.create_table(waiting_queue_name(name), @table_definition)
    get_last_message_index(name)
  end

  defp get_last_message_index(name) do
    {:atomic, keys_list} = :mnesia.transaction(fn -> :mnesia.all_keys(queue_name(name)) end)
    case List.last(Enum.sort(keys_list)) do
      nil -> 0
      last_message_index -> last_message_index
    end
  end

  def delete_queue_tables(name) do
    :mnesia.delete_table(queue_name(name))
    :mnesia.delete_table(waiting_queue_name(name))
  end

  def enqueue_message(name, index, term) do
    :mnesia.transaction(fn -> :mnesia.write(queue_name(name), {queue_name(name), index, term}, :sticky_write) end)
  end

  defp queue_name(name), do: String.to_atom("#{name}_queue")
  defp waiting_queue_name(name), do: String.to_atom("#{name}_waiting_queue")
end
