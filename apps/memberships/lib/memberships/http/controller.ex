defmodule Memberships.Http.Controller do
  import Plug.Conn

  def create(conn, _params) do
    id = UUID.uuid4()

    send_resp(conn, 201, Jason.encode!(%{id: id}))
    # case CreatePerson.execute(params_with_id) do
    #  {:ok, _} ->
    #    send_resp(conn, 201, Jason.encode!(%{id: id}))

    #  {:error, reason} ->
    #    send_resp(conn, 400, Jason.encode!(%{error: to_string(reason)}))
    # end
  end

  # def get(conn, id) do
  #  case GetPersonById.execute(id) do
  #    {:error, :not_found} ->
  #      conn
  #      |> put_resp_content_type("application/json")
  #      |> send_resp(404, Jason.encode!(%{error: "Person not found"}))

  #    {:ok, person} ->
  #      conn
  #      |> put_resp_content_type("application/json")
  #      |> send_resp(
  #        200,
  #        Jason.encode!(person)
  #      )
  #  end
  # end
end
