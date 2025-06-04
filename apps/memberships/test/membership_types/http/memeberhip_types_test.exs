defmodule Memberships.Http.MembershipTypeControllerTest do
  use Memberships.DataCase
  use Memberships.Http.ConnCase

  alias Memberships.MembershipTypes

  @valid_attrs %{
    "name" => "Quarterly Youth",
    "type" => "quarterly",
    "description" => "For students",
    "price_id" => "price_456"
  }

  test "POST /membership-types creates and emits event" do
    conn = build_conn(:post, "/membership-types", @valid_attrs)
    assert conn.status == 201

    %{"id" => id} = Jason.decode!(conn.resp_body)
    assert MembershipTypes.get_membership_type!(id).type == :quarterly
  end

  test "GET /membership_types returns the list" do
    MembershipTypes.create_membership_type(%{
      @valid_attrs
      | "type" => "monthly",
        "name" => "Monthly Youth"
    })

    conn = build_conn(:get, "/membership-types")
    assert conn.status == 200

    list = Jason.decode!(conn.resp_body)
    assert length(list) > 0
  end

  test "POST /membership-types/:id/archive archives it" do
    {:ok, mt} =
      MembershipTypes.create_membership_type(%{
        @valid_attrs
        | "type" => "yearly",
          "name" => "Yearly Youth"
      })

    conn = build_conn(:post, "/membership-types/#{mt.id}/archive")
    assert conn.status == 204

    archived = MembershipTypes.get_membership_type!(mt.id)
    assert archived.archived
  end
end
