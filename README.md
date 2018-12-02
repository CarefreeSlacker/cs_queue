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
