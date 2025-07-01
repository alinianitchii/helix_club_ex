defmodule Payments.Http.Router do
  use Plug.Router
  use Plug.ErrorHandler

  plug(Plug.Parsers,
    parsers: [:json],
    pass: ["application/json"],
    json_decoder: Jason
  )

  plug(:match)
  plug(:dispatch)

  get "" do
    send_resp(conn, 200, Jason.encode!(%{message: "Payments is up and running!"}))
  end

  post "/payments" do
    Payments.Http.Controller.create(conn, conn.body_params)
  end

  get "/payments/:id" do
    Payments.Http.Controller.get(conn, id)
  end

  match _ do
    send_resp(conn, 404, "Not found")
  end
end
