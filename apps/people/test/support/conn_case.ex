defmodule People.Http.ConnCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      import Plug.Test
      import Plug.Conn

      @router People.Http.Router
      @opts @router.init([])

      def build_conn(method, path, body \\ nil) do
        conn =
          conn(method, path, Jason.encode!(body || %{}))
          |> Plug.Conn.put_req_header("content-type", "application/json")
          |> @router.call(@opts)
      end
    end
  end
end
