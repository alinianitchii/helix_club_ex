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

  get "/memberships/:id" do
    Memberships.Http.Controller.get(conn, id)
  end

  # New MembershipType routes. Find the conventions in elixir. I may need to move the router to app level
  get "/membership-types" do
    Memberships.Http.MembershipTypeController.index(conn)
  end

  get "/membership-types/:id" do
    Memberships.Http.MembershipTypeController.show(conn, id)
  end

  post "/membership-types" do
    Memberships.Http.MembershipTypeController.create(conn, conn.body_params)
  end

  put "/membership-types/:id" do
    Memberships.Http.MembershipTypeController.update(conn, id, conn.body_params)
  end

  post "/membership-types/:id/archive" do
    Memberships.Http.MembershipTypeController.archive(conn, id)
  end

  match _ do
    send_resp(conn, 404, "Not found")
  end
end
