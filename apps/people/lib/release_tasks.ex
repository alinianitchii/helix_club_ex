defmodule People.ReleaseTasks do
  @app :people

  def migrate do
    for repo <- repos() do
      ensure_repo_created(repo)
      {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :up, all: true))
    end
  end

  def rollback(repo, version) do
    {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :down, to: version))
  end

  defp repos do
    Application.load(@app)
    Application.fetch_env!(@app, :ecto_repos)
  end

  defp ensure_repo_created(repo) do
    case repo.__adapter__().storage_up(repo.config()) do
      :ok ->
        IO.puts("Database created for #{inspect(repo)}")

      {:error, :already_up} ->
        IO.puts("Database already exists for #{inspect(repo)}")

      {:error, term} ->
        raise "Failed to create database for #{inspect(repo)}: #{inspect(term)}"
    end
  end
end
