defmodule Memberships.Infrastructure.Repositories.MembershipWriteRepo do
  alias Memberships.Infrastructure.Db.Schema.MembershipWriteModel
  alias Memberships.Infrastructure.Db.Repo

  def save(membership, events) when is_list(events) do
    membership_json = serialize_aggregate(membership)

    membership_changeset =
      case Repo.get(MembershipWriteModel, membership.id) do
        nil ->
          %MembershipWriteModel{id: membership.id}
          |> MembershipWriteModel.changeset(%{state: membership_json})

        existing ->
          existing
          |> MembershipWriteModel.changeset(%{state: membership_json})
      end

    Repo.insert_or_update(membership_changeset)
  end

  def save(membership), do: save(membership, [])

  def save_and_publish(membership, events) do
    case save(membership) do
      {:ok, _} ->
        Enum.each(events, &Memberships.EventBus.publish/1)
        {:ok, membership}

      error ->
        error
    end
  end

  defp serialize_aggregate(membership) do
    %{
      "id" => membership.id,
      "person_id" => membership.person_id,
      "duration" => %{
        "type" => Atom.to_string(membership.duration.type),
        "start_date" => Date.to_iso8601(membership.duration.start_date),
        "end_date" => Date.to_iso8601(membership.duration.end_date)
      },
      # TODO
      "payment" => nil,
      "med_cert" => nil
    }
  end

  # defp deserialize_date(nil), do: nil
  # defp deserialize_date(date_string), do: Date.from_iso8601!(date_string)
end
