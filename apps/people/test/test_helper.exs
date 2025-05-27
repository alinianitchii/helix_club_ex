ExUnit.start()

# Start the application and its dependencies
{:ok, _} = Application.ensure_all_started(:people)

# Start the event subscriber for testing
# {:ok, _} = People.EventSubscriber.start_link([])
