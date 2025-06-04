defmodule Memberships.Http.MembershipTypeController do
  import Plug.Conn
  alias Memberships.MembershipTypes

  def index(conn) do
    types = MembershipTypes.list_membership_types()
    send_json(conn, 200, types)
  end

  def show(conn, id) do
    type = MembershipTypes.get_membership_type!(id)
    send_json(conn, 200, type)
  end

  def create(conn, params) do
    case MembershipTypes.create_membership_type(params) do
      {:ok, type} -> send_json(conn, 201, type)
      {:error, changeset} -> send_json(conn, 400, %{errors: changeset_errors(changeset)})
    end
  end

  def update(conn, id, params) do
    type = MembershipTypes.get_membership_type!(id)

    case MembershipTypes.update_membership_type(type, params) do
      {:ok, updated} -> send_json(conn, 200, updated)
      {:error, changeset} -> send_json(conn, 400, %{errors: changeset_errors(changeset)})
    end
  end

  def archive(conn, id) do
    type = MembershipTypes.get_membership_type!(id)

    case MembershipTypes.archive_membership_type(type) do
      {:ok, _} -> send_resp(conn, 204, "")
      {:error, _} -> send_resp(conn, 500, "Error archiving")
    end
  end

  defp send_json(conn, status, body) do
    body = Jason.encode!(body)

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(status, body)
  end

  defp changeset_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Enum.reduce(opts, msg, fn {key, val}, acc ->
        String.replace(acc, "%{#{key}}", to_string(val))
      end)
    end)
  end
end
