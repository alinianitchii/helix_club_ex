defmodule People.Http.Router do
  use Plug.Router
  use Plug.ErrorHandler

  plug(Plug.Parsers,
    parsers: [:json],
    pass: ["application/json"],
    json_decoder: Jason
  )

  plug(:match)
  plug(:dispatch)

  post "/people" do
    People.Http.PersonController.create(conn, conn.body_params)
  end

  post "/people/:id/address" do
    People.Http.PersonController.add_address(conn, id, conn.body_params)
  end

  get "/people/:id" do
    People.Http.PersonController.get(conn, id)
  end

  post "/medical-certificates" do
    MedicalCertificates.Http.Controller.create_request(conn, conn.body_params)
  end

  get "/medical-certificates/:id" do
    MedicalCertificates.Http.Controller.get(conn, id)
  end

  match _ do
    send_resp(conn, 404, "Not found")
  end
end
