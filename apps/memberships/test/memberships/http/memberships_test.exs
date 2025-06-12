defmodule Memberships.Http.MembershipsTest do
  use Memberships.DataCase
  use Memberships.Http.ConnCase

  setup do
    {:ok, mt} =
      Memberships.MembershipTypes.create_membership_type(%{
        "name" => "Annual Membership 2025",
        "type" => "yearly",
        "description" => ""
      })

    {:ok,
     create_membership_fixture: %{
       person_id: UUID.uuid4(),
       start_date: "2023-03-23",
       membership_type_id: mt.id
     }}
  end

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
    test "creates a new membership", %{create_membership_fixture: fixture} do
      {:ok, resp} =
        do_api_call(:post, "/memberships", fixture)

      assert resp.status == 201
      assert Map.get(resp.decoded, "id") != nil
    end
  end

  describe "GET /memberships/:id" do
    test "retrieves a membership by id", %{create_membership_fixture: fixture} do
      {:ok, resp} =
        do_api_call(:post, "/memberships", fixture)

      %{"id" => id} = resp.decoded

      Process.sleep(100)

      {:ok, resp} =
        do_api_call(:get, "/memberships/#{id}")

      assert resp.status == 200
      assert resp.decoded["id"] != nil
      assert resp.decoded["person_id"] == fixture.person_id
      assert resp.decoded["type"] != nil
      assert resp.decoded["start_date"] == fixture.start_date
      assert resp.decoded["end_date"] != nil
      assert resp.decoded["membership_type_id"] == fixture.membership_type_id
    end
  end
end
