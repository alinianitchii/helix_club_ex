defmodule Memberships.Http.MembershipsTest do
  use ExUnit.Case, async: false

  use Memberships.DataCase

  import Plug.Test
  import Plug.Conn

  alias Memberships.Http.Router
  alias Memberships.Infrastructure.Db.Repo

  @opts Router.init([])

  @membership_fixture %{
    person_id: UUID.uuid4(),
    type: "annual",
    start_date: "2023-03-23"
  }

  setup do
    Ecto.Adapters.SQL.Sandbox.mode(Repo, {:shared, self()})

    {:ok, _} = start_supervised({Bandit, plug: Memberships.Http.Router, port: 4001})

    :ok
  end

  defp do_api_call(method, route, data \\ "") do
    conn =
      conn(method, route, Jason.encode!(data))
      |> put_req_header("content-type", "application/json")
      |> Router.call(@opts)

    decoded_resp_body =
      case conn.resp_body != "" do
        true -> Jason.decode!(conn.resp_body)
        false -> nil
      end

    {:ok, %{status: conn.status, decoded: decoded_resp_body}}
  end

  describe "POST /memberships" do
    test "creates a new membership" do
      {:ok, resp} =
        do_api_call(:post, "/memberships", @membership_fixture)

      assert resp.status == 201
      assert Map.get(resp.decoded, "id") != nil
    end
  end

  describe "GET /memberships/:id" do
    test "retrieves a membership by id" do
      {:ok, resp} =
        do_api_call(:post, "/memberships", @membership_fixture)

      %{"id" => id} = resp.decoded

      Process.sleep(100)

      {:ok, resp} =
        do_api_call(:get, "/memberships/#{id}")

      assert resp.status == 200
      assert Map.get(resp.decoded, "id") != nil
    end
  end
end
