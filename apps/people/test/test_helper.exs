ExUnit.start()

# Start the application and its dependencies
{:ok, _} = Application.ensure_all_started(:people)

# Set the sandbox mode for the test database
Ecto.Adapters.SQL.Sandbox.mode(People.Infrastructure.Db.Repo, :manual)

# Start the event subscriber for testing
#{:ok, _} = People.EventSubscriber.start_link([])
