defmodule MedicalCertificates.Domain.MedicalCertificateAggregateTest do
  use ExUnit.Case

  alias MedicalCertificates.Domain.MedicalCertificateAggregate
  alias People.Domain.FullNameValueObject
  alias MedicalCertificates.Domain.ValueObjects

  describe "register medical certificate" do
    test "check value objects initialization" do
      cmd = %MedicalCertificateAggregate.Register{
        id: UUID.uuid4(),
        holder_id: UUID.uuid4(),
        holder_name: "Gino",
        holder_surname: "Mas",
        issue_date: Date.utc_today()
      }

      {:ok, state, _} = MedicalCertificateAggregate.evolve(nil, cmd)

      assert %FullNameValueObject{} = state.holder_full_name
      assert %ValueObjects.Validity{} = state.validity
    end
  end
end
