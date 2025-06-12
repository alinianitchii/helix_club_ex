defmodule Memberships.Application.Command.SubmitApplicationTest do
  alias Memberships.Infrastructure.Db.Schema.MembershipType
  use Memberships.DataCase

  alias Memberships.Application.Command.SubmitApplication

  describe "create submission command" do
    test "with a membership type without price" do
      mem_type = %MembershipType{
        name: "Annual Membership 2025",
        type: :yearly
      }

      {:ok, cmd} =
        SubmitApplication.create_cmd(
          %{
            "id" => UUID.uuid4(),
            "person_id" => UUID.uuid4(),
            "start_date" => "2023-03-23"
          },
          mem_type
        )

      assert %Memberships.Domain.Commands.SubmitFreeApplication{} = cmd
      assert %Date{} = cmd.start_date
    end

    test "with a membership type with a price" do
      mem_type = %MembershipType{
        name: "Annual Membership 2025",
        type: :yearly,
        price: 10
      }

      {:ok, cmd} =
        SubmitApplication.create_cmd(
          %{
            "id" => UUID.uuid4(),
            "person_id" => UUID.uuid4(),
            "start_date" => "2023-03-23"
          },
          mem_type
        )

      assert %Memberships.Domain.Commands.SubmitPaidApplication{} = cmd
      assert cmd.price == mem_type.price

      assert %Date{} = cmd.start_date
    end
  end
end
