defmodule MedicalCertificates.Domain.ValueObjects.Validity do
  defstruct [:issue_date, :status]

  # @valid_statuses [:invalid, :valid]

  def new(), do: {:ok, %__MODULE__{status: :unknown}}

  def new(%Date{} = issue_date) do
    case Date.before?(issue_date, Date.add(Date.utc_today(), -60)) do
      true -> {:ok, %__MODULE__{issue_date: issue_date, status: :invalid}}
      false -> {:ok, %__MODULE__{issue_date: issue_date, status: :valid}}
    end
  end

  def new(_), do: {:error, DomainError.new(:invalid_value, "Issue date must be a valid date")}
end
