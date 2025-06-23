defmodule MedicalCertificates.Integration.Commands.RequestMedicalCertificate do
  @derive Jason.Encoder
  defstruct [:holder_id]

  # TODO: add validation
  def new(%{holder_id: holder_id}) do
    %__MODULE__{holder_id: holder_id}
  end
end
