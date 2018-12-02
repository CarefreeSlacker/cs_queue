defmodule CsQueue.Queue.QueueManager do
  @moduledoc """
  Perform monitoring for
  """

  use GenServer
  alias CsQueue.Mnesia.Context, as: MnesiaContext

  def start_link(%{name: queue_name} = opts) when is_binary(queue_name) do
    GenServer.start_link(__MODULE__, opts, name: global_name(queue_name))
  end

  def start_link(%{}), do: raise("CsQueue queue must contain queue name")

  def init(opts) do
    send(self(), {:initialize, opts})
    {:ok, %{ready: false}}
  end

  @doc """
  Gets queue name and callback function with arity 1.
  Return {:error, :no_queue} if no worker with that name.
  If worker exist - pass its pid as argument to callback function and return evaluation result.
  """
  @spec safe_evaluate_for_pid(binary, function) :: {:error, :no_queue} | any
  def safe_evaluate_for_pid(queue_name, function) do
    case check_if_queue_exist(queue_name) do
      nil -> {:error, :no_queue}
      pid -> function.(pid)
    end
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

  def get_message_from_queue(queue_name) do
    safe_evaluate_for_pid(queue_name, fn pid ->
      GenServer.call(pid, :get_message)
    end)
  end

  def confirm_message_delivery(queue_name, message_index, true) do
    safe_evaluate_for_pid(queue_name, fn pid ->
      GenServer.call(pid, {:confirm_delivery, message_index})
    end)
  end

  def confirm_message_delivery(queue_name, message_index, false) do
    safe_evaluate_for_pid(queue_name, fn pid ->
      GenServer.cast(pid, {:confirm_delivery, message_index})
    end)
  end

  def reject_message_delivery(queue_name, message_index, true) do
    safe_evaluate_for_pid(queue_name, fn pid ->
      GenServer.call(pid, {:reject_delivery, message_index})
    end)
  end

  def reject_message_delivery(queue_name, message_index, false) do
    safe_evaluate_for_pid(queue_name, fn pid ->
      GenServer.cast(pid, {:reject_delivery, message_index})
    end)
  end

  def handle_info({:initialize, %{name: name} = opts}, state) do
    max_message_index = MnesiaContext.initialize_queue_tables(name)
    {:noreply, Map.merge(state, %{max_message_index: max_message_index, ready: true, name: name})}
  end

  def handle_call(:remove_queues, _from, %{name: name} = state) do
    MnesiaContext.delete_queue_tables(name)
    {:reply, :ok, state}
  end

  def handle_call(:get_queue_messages, _from, state) do
    {:reply, %{queue_messages: [], waiting_queue: []}, state}
  end

  def handle_call({:enqueue_message, term}, _from, %{ready: false} = state) do
    busy_call_reply(state)
  end

  def handle_call(
        {:enqueue_message, term},
        _from,
        %{name: name, ready: true, max_message_index: index} = state
      ) do
    MnesiaContext.enqueue_message(name, index + 1, term)
    {:reply, :ok, Map.merge(state, %{max_message_index: index + 1})}
  end

  def handle_call(:get_message, _from, %{ready: false} = state) do
    busy_call_reply(state)
  end

  def handle_call(:get_message, _from, %{name: name, ready: true} = state) do
    message = MnesiaContext.get_message_and_move_to_waiting_queue(name)
    {:reply, message, state}
  end

  def handle_call({:confirm_delivery, _message_index}, _from, %{ready: false} = state) do
    busy_call_reply(state)
  end

  def handle_call(
        {:confirm_delivery, message_index},
        _from,
        %{name: queue_name, ready: true} = state
      ) do
    result = MnesiaContext.confirm_delivery(queue_name, message_index)
    {:reply, result, state}
  end

  def handle_cast({:confirm_delivery, message_index}, %{ready: false} = state) do
    {:noreply, state}
  end

  def handle_cast({:confirm_delivery, message_index}, %{name: queue_name, ready: true} = state) do
    MnesiaContext.confirm_delivery(queue_name, message_index)
    {:noreply, state}
  end

  def handle_call({:reject_delivery, _message_index}, _from, %{ready: false} = state) do
    busy_call_reply(state)
  end

  def handle_call(
        {:reject_delivery, message_index},
        _from,
        %{max_message_index: max_message_index, name: queue_name, ready: true} = state
      ) do
    result = MnesiaContext.reject_delivery(queue_name, message_index, max_message_index + 1)
    {:reply, result, Map.merge(state, %{max_message_index: max_message_index + 1})}
  end

  def handle_cast({:reject_delivery, message_index}, %{ready: false} = state) do
    {:noreply, state}
  end

  def handle_cast(
        {:reject_delivery, message_index},
        %{max_message_index: max_message_index, name: queue_name, ready: true} = state
      ) do
    MnesiaContext.reject_delivery(queue_name, message_index, max_message_index + 1)
    {:noreply, Map.merge(state, %{max_message_index: max_message_index + 1})}
  end

  defp global_name(queue_name), do: {:global, queue_name}
  defp busy_call_reply(state), do: {:reply, {:error, :please_repeat_later}, state}
end
