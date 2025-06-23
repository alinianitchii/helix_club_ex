defmodule MedicalCertificates.Application.Queries.GetById do
  alias MedicalCertificates.Infrastructure.Repositories.MedicalCertificatesRepo

  def execute(id) do
    case MedicalCertificatesRepo.get_by_id(id) do
      nil -> {:error, :not_found}
      medical_certificate -> {:ok, medical_certificate}
    end
  end
end
