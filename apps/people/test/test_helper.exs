ExUnit.start()

{:ok, _} = Application.ensure_all_started(:people)

Ecto.Adapters.SQL.Sandbox.mode(People.Infrastructure.Db.Repo, :manual)

#{:ok, _} = People.EventSubscriber.start_link([])
