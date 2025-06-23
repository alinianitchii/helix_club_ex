defmodule MedicalCertificates.Domain.MedicalCertificateAggregateTest do
  use ExUnit.Case

  alias MedicalCertificates.Domain.MedicalCertificateAggregate
  alias People.Domain.FullNameValueObject
  alias MedicalCertificates.Domain.ValueObjects

  describe "create medical certificate request" do
    test "sets holder data" do
      cmd = %MedicalCertificateAggregate.CreateRequest{
        id: UUID.uuid4(),
        holder_id: UUID.uuid4(),
        holder_name: "Gino",
        holder_surname: "Mas"
      }

      {:ok, state, _} = MedicalCertificateAggregate.evolve(nil, cmd)

      assert state.holder_full_name == %FullNameValueObject{
               name: cmd.holder_name,
               surname: cmd.holder_surname
             }
    end

    test "sets request date" do
      cmd = %MedicalCertificateAggregate.CreateRequest{
        id: UUID.uuid4(),
        holder_id: UUID.uuid4(),
        holder_name: "Gino",
        holder_surname: "Mas"
      }

      {:ok, state, _} = MedicalCertificateAggregate.evolve(nil, cmd)

      assert state.request_date == %ValueObjects.ReqeustDate{date: Date.utc_today()}
    end

    test "sets certificate status as unknown" do
      cmd = %MedicalCertificateAggregate.CreateRequest{
        id: UUID.uuid4(),
        holder_id: UUID.uuid4(),
        holder_name: "Gino",
        holder_surname: "Mas"
      }

      {:ok, state, _} = MedicalCertificateAggregate.evolve(nil, cmd)
      assert state.validity == %ValueObjects.Validity{status: :unknown, issue_date: nil}
    end
  end

  describe "register medical certificate" do
    test "issue date is evaluated and status changes" do
      cmd = %MedicalCertificateAggregate.CreateRequest{
        id: UUID.uuid4(),
        holder_id: UUID.uuid4(),
        holder_name: "Gino",
        holder_surname: "Mas"
      }

      {:ok, state, _} = MedicalCertificateAggregate.evolve(nil, cmd)

      cmd = %MedicalCertificateAggregate.Register{issue_date: Date.utc_today()}

      {:ok, state, _} = MedicalCertificateAggregate.evolve(state, cmd)

      assert %ValueObjects.Validity{issue_date: issue_date, status: :valid} = state.validity
      assert %Date{} = issue_date
    end
  end
end
