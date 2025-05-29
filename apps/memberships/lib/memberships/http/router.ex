defmodule Memberships.Http.Router do
  use Plug.Router
  use Plug.ErrorHandler

  plug(Plug.Parsers,
    parsers: [:json],
    pass: ["application/json"],
    json_decoder: Jason
  )

  plug(:match)
  plug(:dispatch)

  post "/memberships" do
    Memberships.Http.Controller.create(conn, conn.body_params)
  end

  # get "/memberships/:id" do
  #  Memberships.Http.PersonController.get(conn, id)
  # end

  match _ do
    send_resp(conn, 404, "Not found")
  end
end
