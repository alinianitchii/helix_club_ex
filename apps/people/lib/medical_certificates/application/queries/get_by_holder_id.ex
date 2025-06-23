defmodule MedicalCertificates.Application.Queries.GetByHolderId do
  alias MedicalCertificates.Infrastructure.Repositories.MedicalCertificatesRepo

  def execute(holder_id) do
    MedicalCertificatesRepo.get_by_holder_id(holder_id)
  end
end
