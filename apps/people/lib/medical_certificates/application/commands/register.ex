defmodule MedicalCertificates.Application.Commands.Register do
  alias MedicalCertificates.Domain.MedicalCertificateAggregate
  alias MedicalCertificates.Infrastructure.Repositories.MedicalCertificatesRepo

  def execute(%{
        "id" => id,
        "issue_date" => issue_date_str
      }) do
    issue_date = Date.from_iso8601!(issue_date_str)
    command = %MedicalCertificateAggregate.Register{issue_date: issue_date}

    with {:ok, state} <- MedicalCertificatesRepo.get_aggregate_by_id(id),
         {:ok, state, event} <- MedicalCertificateAggregate.evolve(state, command),
         {:ok, _} <- MedicalCertificatesRepo.save_and_publish(state, [event]) do
      {:ok}
    end
  end
end
