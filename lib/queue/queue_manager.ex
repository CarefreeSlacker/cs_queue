defmodule CsQueue.Queue.QueueManager do
  @moduledoc """
  Perform monitoring for
  """

  use GenServer
  alias CsQueue.Mnesia.Context

  def start_link(%{name: queue_name} = opts) when is_binary(queue_name) do
    GenServer.start_link(__MODULE__, opts, name: global_name(queue_name))
  end

  def start_link(%{}), do: raise("CsQueue queue must contain queue name")

  def init(opts) do
    send(self(), {:initialize, opts})
    {:ok, %{ready: false}}
  end

  def check_if_queue_exist(queue_name) do
    GenServer.whereis(global_name(queue_name))
  end

  def remove_queues(pid) do
    GenServer.call(pid, :remove_queues)
  end

  def get_queue_messages(pid) do
    GenServer.call(pid, :get_queue_messages)
  end

  def enqueue_message(pid, term) do
    GenServer.call(pid, {:enqueue_message, term})
  end

  def handle_info({:initialize, %{name: name} = opts}, state) do
    max_message_index = Context.initialize_queue_tables(name)
    {:noreply, Map.merge(state, %{max_message_index: max_message_index, ready: true, name: name})}
  end

  def handle_call(:remove_queues, _from, %{name: name} = state) do
    Context.delete_queue_tables(name)
    {:reply, :ok, state}
  end

  def handle_call(:get_queue_messages, _from, state) do
    {:reply, %{queue_messages: [], waiting_queue: []}, state}
  end

  def handle_call({:enqueue_message, term}, _from, %{ready: false} = state) do
    {:reply, {:error, :please_repeat}, state}
  end

  def handle_call({:enqueue_message, term}, _from, %{name: name, ready: true, max_message_index: index} = state) do
    Context.enqueue_message(name, index + 1, term)
    {:reply, :ok, Map.merge(state, %{max_message_index: index + 1})}
  end

  defp global_name(queue_name), do: {:global, queue_name}
end
