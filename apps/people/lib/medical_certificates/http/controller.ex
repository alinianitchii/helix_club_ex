defmodule MedicalCertificates.Http.Controller do
  import Plug.Conn

  alias Payments.Application.Queries.GetById
  alias MedicalCertificates.Application.Commands.{CreateRequest, Register}
  alias MedicalCertificates.Application.Queries.GetById

  def create_request(conn, params) do
    id = UUID.uuid4()
    params_with_id = params |> Map.put("id", id)

    case CreateRequest.execute(params_with_id) do
      {:ok, _} ->
        send_resp(conn, 201, Jason.encode!(%{id: id}))

      {:error, reason} ->
        send_resp(conn, 400, Jason.encode!(%{error: to_string(reason)}))
    end
  end

  def register(conn, id, params) do
    params_with_id = params |> Map.put("id", id)

    case Register.execute(params_with_id) do
      {:ok} ->
        send_resp(conn, 201, "")

      {:error, reason} ->
        send_resp(conn, 400, Jason.encode!(%{error: to_string(reason)}))
    end
  end

  def get(conn, id) do
    case GetById.execute(id) do
      {:error, :not_found} ->
        conn
        |> put_resp_content_type("application/json")
        |> send_resp(404, Jason.encode!(%{error: "Medical certificate not found"}))

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
