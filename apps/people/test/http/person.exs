defmodule People.Http.PersonTest do
  use ExUnit.Case, async: false

  use People.DataCase
  import Plug.Test
  import Plug.Conn

  alias People.Http.Router
  alias People.Infrastructure.Db.Repo

  @opts Router.init([])

  @person_fixture %{
    "name" => "Ciccio",
    "surname" => "Pasticcio",
    "email" => "ciccio.pasticcio@example.com",
    "date_of_birth" => "1990-01-01"
  }

  setup do
    Ecto.Adapters.SQL.Sandbox.mode(Repo, {:shared, self()})

    {:ok, _} = start_supervised({Bandit, plug: People.Http.Router, port: 4001})

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

  describe "POST /people" do
    test "creates a new person" do
      {:ok, resp} =
        do_api_call(:post, "/people", @person_fixture)

      assert resp.status == 201
      assert Map.get(resp.decoded, "id") != nil
    end
  end

  describe "GET /people/:id" do
    test "retrieves a person by id" do
      {:ok, resp} =
        do_api_call(:post, "/people", @person_fixture)

      %{"id" => id} = resp.decoded

      # TODO: its a really bad solution but it's ok for the moment
      Process.sleep(100)

      {:ok, resp} = do_api_call(:get, "/people/#{id}")

      assert resp.status == 200

      assert resp.decoded["id"] == id
      assert resp.decoded["name"] == @person_fixture["name"]
      assert resp.decoded["surname"] == @person_fixture["surname"]
      assert resp.decoded["email"] == @person_fixture["email"]
      assert resp.decoded["date_of_birth"] == @person_fixture["date_of_birth"]
    end

    test "returns 404 for non-existent person" do
      non_existent_id = UUID.uuid4()

      {:ok, resp} = do_api_call(:get, "/people/#{non_existent_id}")

      assert resp.status == 404
    end
  end

  describe "POST /people/:id/address" do
    test "adds an address to the person" do
      {:ok, resp} = do_api_call(:post, "/people", @person_fixture)

      %{"id" => id} = resp.decoded

      address_fixture = %{
        "street" => "Via Giulio Natta",
        "number" => "59",
        "city" => "Arcore",
        "postal_code" => "20862",
        "state_or_province" => "MB",
        "country" => "Italia"
      }

      {:ok, resp} = do_api_call(:post, "/people/#{id}/address", address_fixture)

      assert resp.status == 201

      # TODO: its a really bad solution but it's ok for the moment
      Process.sleep(100)

      {:ok, resp} = do_api_call(:get, "/people/#{id}")

      assert resp.status == 200
      assert resp.decoded["address"] == address_fixture
    end
  end
end
