defmodule MedicalCertificates.Domain.ValueObjects.ReqeustDate do
  defstruct [:date]

  def new(), do: {:ok, %__MODULE__{date: Date.utc_today()}}
  def new(%Date{} = date), do: {:ok, %__MODULE__{date: date}}
  def new(_), do: {:error, DomainError.new(:invalid_value, "Reqeust date must be a valid date")}
end
