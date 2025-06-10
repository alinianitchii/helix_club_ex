defmodule Payments.Http.ConnCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      import Plug.Test
      import Plug.Conn

      @router Payments.Http.Router
      @opts @router.init([])

      def build_conn(method, path, body \\ nil) do
        conn =
          conn(method, path, Jason.encode!(body || %{}))
          |> Plug.Conn.put_req_header("content-type", "application/json")
          |> @router.call(@opts)
      end

      defp do_api_call(method, path, data \\ "") do
        conn = build_conn(method, path, data)

        decoded_resp_body =
          case conn.resp_body != "" do
            true -> Jason.decode!(conn.resp_body)
            false -> nil
          end

        {:ok, %{status: conn.status, decoded: decoded_resp_body}}
      end
    end
  end
end
