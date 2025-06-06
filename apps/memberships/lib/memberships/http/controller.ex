defmodule Memberships.Http.Controller do
  import Plug.Conn

  alias Memberships.Application.Command.SubmitApplication
  alias Memberships.Application.Query.GetMembershipById

  def create(conn, params) do
    id = UUID.uuid4()

    params_with_id = Map.merge(params, %{"id" => id})

    case SubmitApplication.execute(params_with_id) do
      {:ok, _} ->
        send_resp(conn, 201, Jason.encode!(%{id: id}))

      {:error, reason} ->
        send_resp(conn, 400, Jason.encode!(%{error: to_string(reason)}))
    end
  end

  def get(conn, id) do
    case GetMembershipById.execute(id) do
      {:error, :not_found} ->
        conn
        |> put_resp_content_type("application/json")
        |> send_resp(404, Jason.encode!(%{error: "Memvership not found"}))

      {:ok, membership} ->
        conn
        |> put_resp_content_type("application/json")
        |> send_resp(
          200,
          Jason.encode!(membership)
        )
    end
  end
end
