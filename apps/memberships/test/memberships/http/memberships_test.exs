defmodule Memberships.Http.MembershipsTest do
  use ExUnit.Case, async: false

  use Memberships.DataCase
  use Memberships.Http.ConnCase

  @membership_fixture %{
    person_id: UUID.uuid4(),
    type: "annual",
    start_date: "2023-03-23"
  }

  # if I'm ok with this implementation it can be moved to ConnCase
  defp do_api_call(method, path, data \\ "") do
    conn = build_conn(method, path, data)

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
