defmodule MedicalCertificates.Application.Commands.CreateRequest do
  alias MedicalCertificates.Domain.MedicalCertificateAggregate
  alias MedicalCertificates.Infrastructure.Repositories.MedicalCertificatesRepo

  def execute(%{
        "id" => id,
        "holder_id" => holder_id,
        "holder_name" => holder_name,
        "holder_surname" => holder_surname
      }) do
    command = %MedicalCertificateAggregate.CreateRequest{
      id: id,
      holder_id: holder_id,
      holder_name: holder_name,
      holder_surname: holder_surname
    }

    with {:ok, state, event} <- MedicalCertificateAggregate.evolve(nil, command),
         {:ok, _} <- MedicalCertificatesRepo.save_and_publish(state, [event]) do
      {:ok, id}
    end
  end
end
