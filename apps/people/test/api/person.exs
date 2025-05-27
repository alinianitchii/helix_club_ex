defmodule People.API.PersonTest do
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

  describe "POST /people" do
    test "creates a new person" do
      conn =
        conn(:post, "/people", Jason.encode!(@person_fixture))
        |> put_req_header("content-type", "application/json")
        |> Router.call(@opts)

      assert conn.status == 201
      assert %{"id" => _id} = Jason.decode!(conn.resp_body)
    end
  end

  describe "GET /people/:id" do
    test "retrieves a person by id" do
      conn =
        conn(:post, "/people", Jason.encode!(@person_fixture))
        |> put_req_header("content-type", "application/json")
        |> Router.call(@opts)

      %{"id" => id} = Jason.decode!(conn.resp_body)

      # TODO: its a really bad solution but it's ok for the moment
      Process.sleep(100)

      conn =
        conn(:get, "/people/#{id}")
        |> Router.call(@opts)

      assert conn.status == 200
      retrieved_person = Jason.decode!(conn.resp_body)
      assert retrieved_person["id"] == id
      assert retrieved_person["name"] == @person_fixture["name"]
      assert retrieved_person["surname"] == @person_fixture["surname"]
      assert retrieved_person["email"] == @person_fixture["email"]
      assert retrieved_person["date_of_birth"] == @person_fixture["date_of_birth"]
    end

    test "returns 404 for non-existent person" do
      non_existent_id = UUID.uuid4()

      conn =
        conn(:get, "/people/#{non_existent_id}")
        |> Router.call(@opts)

      assert conn.status == 404
    end
  end

  describe "POST /people/:id/address" do
    test "adds an address to the person" do
      conn =
        conn(:post, "/people", Jason.encode!(@person_fixture))
        |> put_req_header("content-type", "application/json")
        |> Router.call(@opts)

      %{"id" => id} = Jason.decode!(conn.resp_body)

      conn =
        conn(
          :post,
          "/people/#{id}/address",
          Jason.encode!(%{
            "id" => id,
            "street" => "Via Giulio Natta",
            "number" => "59",
            "city" => "Arcore",
            "postal_code" => "20862",
            "state_or_province" => "MB",
            "country" => "Italia"
          })
        )
        |> put_req_header("content-type", "application/json")
        |> Router.call(@opts)

      assert conn.status == 201

      expected_address = %{
        "street" => "Via Giulio Natta",
        "number" => "59",
        "city" => "Arcore",
        "postal_code" => "20862",
        "state_or_province" => "MB",
        "country" => "Italia"
      }

      # TODO: its a really bad solution but it's ok for the moment
      Process.sleep(100)

      conn =
        conn(:get, "/people/#{id}")
        |> Router.call(@opts)

      assert retrieved_person = Jason.decode!(conn.resp_body)
      assert retrieved_person["address"] == expected_address
    end
  end
end
