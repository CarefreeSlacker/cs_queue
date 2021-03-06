defmodule CsQueue.MixProject do
  use Mix.Project

  def project do
    [
      app: :cs_queue,
      version: "0.1.0",
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      mod: [],
      deps: deps(),
      description: description(),
      package: package()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {CsQueue.Application, []},
      extra_applications: logger_application()
    ]
  end

  def logger_application do
    if(Mix.env() == :dev, do: [:logger], else: [])
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"},
    ]
  end

  defp description() do
    "Simple queue client. Use mnesia for storing messages"
  end

  defp package() do
    [
      # This option is only needed when you don't want to use the OTP application name
      name: "cs_queue",
      # These are the default files included in the package
      files: ~w(lib .formatter.exs mix.exs README*),
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/CarefreeSlacker/cs_queue"}
    ]
  end
end
