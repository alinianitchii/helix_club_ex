ExUnit.start()

# Start the application and Ecto repository
#{:ok, _} = Application.ensure_all_started(:people)

# Configure sandbox mode
#Ecto.Adapters.SQL.Sandbox.mode(People.Infrastructure.Database.Repo, :manual)

# Start the event subscriber
# {:ok, _} = People.EventSubscriber.start_link([])
