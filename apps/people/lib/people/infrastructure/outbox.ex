defmodule People.Infrastructure.Outbox do
  alias People.Infrastructure.Db.Schema.OutboxSchema
  alias People.Infrastructure.Db.Repo

  def enqueue_many(entries) when is_list(entries) do
    naive_now = DateTime.utc_now() |> DateTime.truncate(:second) |> DateTime.to_naive()

    entries_with_timestamps =
      Enum.map(entries, fn entry ->
        Map.merge(entry, %{
          status: "pending",
          attempts: 0,
          inserted_at: naive_now,
          updated_at: naive_now
        })
      end)

    Repo.insert_all(OutboxSchema, entries_with_timestamps)
  end

  def enqueue(attrs, opts \\ []) do
    %OutboxSchema{}
    |> OutboxSchema.changeset(attrs)
    |> Repo.insert!(opts)
  end

  def one(queryable, opts \\ []) do
    Repo.one(queryable, opts)
  end
end
