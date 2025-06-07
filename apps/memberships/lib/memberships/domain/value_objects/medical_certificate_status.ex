defmodule Memberships.Domain.MedicalCertificateStatusValueObject do
  defstruct [:status]

  @valid_statuses [:incomplete, :valid, :invalid]

  def new(), do: {:ok, %__MODULE__{status: :incomplete}}

  def change(new_status) when new_status not in @valid_statuses do
    {:error, %DomainError{code: :invalid_value, message: "Invalid medical certification status"}}
  end

  def change(new_status) do
    {:ok, %__MODULE__{status: new_status}}
  end

  def is_valid?(%__MODULE__{status: current}) do
    current == :valid
  end
end
