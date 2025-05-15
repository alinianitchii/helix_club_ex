defmodule People.Domain.EmailValueObject do
  @enforce_keys [:value]
  defstruct [:value]

  @email_regex ~r/^[\w.!#$%&’*+\-\/=?\^`{|}~]+@[a-zA-Z0-9-]+(\.[a-zA-Z0-9-]+)*$/i

  def new(raw_email) when is_binary(raw_email) do
    with {:ok, valid_email} <- normalize_and_validate(raw_email) do
      {:ok, %__MODULE__{value: valid_email}}
    end
  end

  defp normalize_and_validate(email) do
    email |> normalize() |> validate()
  end

  defp normalize(email) do
    email
    |> String.trim()
    |> String.replace(~r/\s+/, "")
    |> String.downcase()
  end

  defp validate(email) do
    if email =~ @email_regex do
      {:ok, email}
    else
      {:error, DomainError.new(:invalid_email, "Invalid email")}
    end
  end
end
