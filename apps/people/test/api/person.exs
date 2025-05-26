defmodule People.API.PersonTest do
  use ExUnit.Case, async: false
  use People.DataCase
  import Plug.Test
  import Plug.Conn

  alias People.Http.Router
  alias People.Infrastructure.Db.Repo

  @opts Router.init([])

  setup do
    {:ok, server_pid} = start_supervised({Bandit, plug: People.Http.Router, port: 4001})
    Ecto.Adapters.SQL.Sandbox.allow(Repo, self(), server_pid)

    Process.register(self(), :test_process)

    :ok
  end

  describe "POST /people" do
    test "creates a new person" do
      person_data = %{
        "name" => "Ciccio",
        "surname" => "Pasticcio",
        "email" => "ciccio.pasticcio@example.com",
        "date_of_birth" => "1990-01-01"
      }

      conn =
        conn(:post, "/people", Jason.encode!(person_data))
        |> put_req_header("content-type", "application/json")
        |> Router.call(@opts)

      assert conn.status == 201
      assert %{"id" => _id} = Jason.decode!(conn.resp_body)
    end
  end

  describe "GET /people/:id" do
    test "retrieves a person by id" do
      person_data = %{
        "name" => "Ciccio",
        "surname" => "Pasticcio",
        "email" => "ciccio.pasticcio@example.com",
        "date_of_birth" => "1992-02-02"
      }

      conn = conn(:post, "/people", Jason.encode!(person_data))
      |> put_req_header("content-type", "application/json")
      |> Router.call(@opts)

      %{"id" => id} = Jason.decode!(conn.resp_body)

      assert_receive {:read_model_updated, ^id}, 5000

      conn =
        conn(:get, "/people/#{id}")
        |> Router.call(@opts)

      assert conn.status == 200
      retrieved_person = Jason.decode!(conn.resp_body)
      assert retrieved_person["id"] == id
      assert retrieved_person["name"] == person_data["name"]
      assert retrieved_person["surname"] == person_data["surname"]
      assert retrieved_person["email"] == person_data["email"]
      assert retrieved_person["date_of_birth"] == person_data["date_of_birth"]
    end

    test "returns 404 for non-existent person" do
      non_existent_id = UUID.uuid4()
      conn =
        conn(:get, "/people/#{non_existent_id}")
        |> Router.call(@opts)

      assert conn.status == 404
    end
  end
end
