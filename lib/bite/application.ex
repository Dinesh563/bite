defmodule Bite.Application do
  # See https://hexdocs.pm/elixir/Application.html+3.

  # for more information on OTP Applications
  @moduledoc false
  require Logger
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    create_db(Bite.Repo.config())

    children = [
      # Start the Ecto repository
      Bite.Repo,
      worker(Task, [fn -> migrate() end], restart: :temporary, id: "migrate_worker"),

      # Start the endpoint when the application starts
      BiteWeb.Endpoint
      # Starts a worker by calling: Bite.Worker.start_link(arg)
      # {Bite.Worker, arg},
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Bite.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp create_db(config) do
    config
    |> Ecto.Adapters.Postgres.storage_up()
    |> case do
      :ok ->
        Logger.info("#{config[:database]} database created successfully")

      {:error, :already_up} ->
        Logger.info("#{config[:database]} database already created.")

      {:error, error} ->
        Logger.info("Error while creating #{config[:database]} database #{inspect(error)}")
    end
  end

  defp migrate() do
    Ecto.Migrator.run(Bite.Repo, "#{:code.priv_dir(:bite)}/repo/migrations", :up,
      all: true
    )
  end
  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    BiteWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
