defmodule People.Http.PersonController do
  import Plug.Conn

  alias People.Application.Command.CreatePerson
  alias People.Application.Query.GetPersonById

  def create(conn, params) do
    IO.inspect(params)
    case CreatePerson.execute(params) do
      {:ok, _person_id} ->
        send_resp(conn, 201, Jason.encode!(%{ok: "ok"}))

      {:error, reason} ->
        send_resp(conn, 400, Jason.encode!(%{error: to_string(reason)}))
    end
  end

  def get(conn, id) do
    case GetPersonById.execute(id) do
      {:error, :not_found} ->
        conn
        |> put_resp_content_type("application/json")
        |> send_resp(404, Jason.encode!(%{error: "Person not found"}))

      {:ok, person} ->
        conn
        |> put_resp_content_type("application/json")
        |> send_resp(
          200,
          Jason.encode!(person)
        )
    end
  end
end
