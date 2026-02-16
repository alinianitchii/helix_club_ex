### How to run tests locally

To run tests locally, you can use the following command:

```bash
mix test
``` 

But to make it actually work you need first to set up the environment variable for MIX_ENV to test, and also to have a local PostgreSQL instance running with the required databases and credentials. You can do this by running:

```bash
MIX_ENV=test
mix deps.get
mix ecto.create
mix ecto.migrate
```

There is no need to run a postgres docker container to make them work.
