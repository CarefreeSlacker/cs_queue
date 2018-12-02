# CsQueue

Реализация менеджера очередей с гарантией доставки сообщения и произвольным содержимым.

## Installation

1. Add to dependencies

```elixir
def deps do
  [
    {:cs_queue, "~> 0.1.0"}
  ]
end
```

2. [Optional] Write to the project configuration path to the directory for queue copies

```elixir
  config :mnesia, dir: 'mnesia/#{Mix.env}/#{node()}'
```

By default if places in the root of your project and called 'Mnesia.<node()>'

3. Add mnesia directory to .gitignore.


```elixir
/Mnesia.*/ # Example for default. If you specified different folder on step 2 write your directory
```

4. Add application to extra starting applications in your mix.exs.

```elixir
  def application do
    [
      ...,
      extra_applications: [..., :cs_queue, ....],
      ...
    ]
  end
```

That's it. Now you can use API.

Two main modules `CsQueue.Api.ConsumerApi` and `CsQueue.Api.ProducerApi`
It allows you to initialize and destroy queues. Enqueue, get, confirm and reject messages.

Description:

### ProducerApi

*initialize_queue(binary) :: :ok | {:error, :allready_exist}*

Initialize queue with given name. And return `:ok` if everything allright.
Or return `{:error, :allready_exist}` Nuff Said.

*@spec terminate_queue(binary, boolean) ::
           :ok
           | {:error, :no_queue}
           | {:ok, %{queue_messages: list(any), waiting_queue: list(any)}}*

Terminate queue with given name.
First argument is queue name.
Second argument tells do you need to receive all queued messages, `boolean`. `false` by default.
If second argument `false` and given queue exists - returns `:ok`
If second arument `true` and given queue exists - returns {:ok, %{queue_messages: list(any), waiting_queue: list(any)}}
Or return error `{:error, :no_queue}` if no queue with given name.

*@spec enqueue_message(binary, any) :: :ok | {:error, :no_queue} | {:error, :please_repeat_later}*

Enqueue message to the end of the queue and return `:ok` if everything allright.
Or return error those looks like `{:error, reason}`
Where `reason` could be:
* :no_queue - no queue with given name
* :please_repeat_later - worker is not loaded currently. Consumer must repeat it soon.

### ConsumerApi

*@spec get_message_from_queue(binary) ::
           {:ok, %{index: integer, term: term}}
           | {:error, :no_message}
           | {:error, :no_queue}
           | {:error, :please_repeat_later}*

Gets message from given queue those looks like `{:ok, %{index: integer, term: any}}`.
Where `index` is order number of message. Could be used to confirm or reject message delivery.
Term - message itself. Could have any format.

Or return error those looks like `{:error, reason}`. Reason could be:
* :no_message - there is no messages in queue.
* :no_queue - no queue with given name.
* :please_repeat_later - worker is not loaded currently. Consumer must repeat it soon.

*@spec confirm_message_delivery(binary, integer, boolean) ::
           :ok
           | {:ok, %{index: integer, term: term}}
           | {:error, :no_message}
           | {:error, :no_queue}
           | {:error, :please_repeat_later}*
           
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

*@spec reject_message_delivery(binary, integer) ::
           :ok
           | {:ok, %{index: integer, term: term}}
           | {:error, :no_message}
           | {:error, :no_queue}
           | {:error, :please_repeat_later}*
           
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
  

## Exercise
Реализовать на Elixir персистентную очередь сообщений со следующими возможностями:

- Добавить сообщение в конец очереди (add)

- Взять следующее сообщение из очереди на обработку (get)

- Подтвердить успешную обработку (ack)

- Сообщить об ошибке обработки (reject) — сообщение возвращается в конец очереди

Обработчиков сообщений может быть несколько, и они работают независимо друг от друга

1. результат работы - Elixir-библиотека, которую можно будет использовать для организации очереди в существующем приложении

2. в сообщениях содержится любой валидный term - на усмотрение кандидата

3. ack/reject после get ждем вечно

4. можно считать, что очередь всегда поместится в память

Очередь должна сохранять свое состояние между рестартами, в том числе внештатными, не терять сообщения и их статусы, успешно обработанные сообщения сохранять не надо, потребители - асинхронны и их может быть любое количество в разумных пределах, приложение может завершить свою работу в любой момент, в том числе внештатно. Выбор технологий и алгоритмов на усмотрение кандидата в заявленных рамках.
