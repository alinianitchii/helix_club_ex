defmodule Memberships.Domain.MedicalCertificateStatusValueObjectTest do
  use ExUnit.Case

  alias Memberships.Domain.MedicalCertificateStatusValueObject

  describe "new" do
    test "default status" do
      {:ok, med_cert_status} = MedicalCertificateStatusValueObject.new()

      assert med_cert_status.status == :incomplete
    end
  end

  describe "change/1" do
    test "to a not existing status" do
      {:error, reason} = MedicalCertificateStatusValueObject.change(:foo)

      assert reason == %DomainError{
               code: :invalid_value,
               message: "Invalid medical certification status"
             }
    end

    test "to valid status" do
      {:ok, med_cert_status} = MedicalCertificateStatusValueObject.change(:valid)

      assert med_cert_status.status == :valid
    end
  end
end
