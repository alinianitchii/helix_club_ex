defmodule People.Domain.FullNameValueObject do
  defstruct [:name, :surname]

  @type t :: %__MODULE__{
          name: String.t(),
          surname: String.t()
        }

  def create(name, surname) do
    with :ok <- validate_field(name, :name),
         :ok <- validate_field(surname, :surname) do
      {:ok,
       %__MODULE__{
         name: normalize_name(name),
         surname: normalize_name(surname)
       }}
    end
  end

  # Private validation functions
  defp validate_field(nil, field),
    do: {:error, DomainError.new(:empty_value, "#{field_name(field)} cannot be empty", field)}

  defp validate_field(value, field) do
    with :ok <- validate_non_empty(value, field),
         :ok <- validate_characters(value, field) do
      :ok
    end
  end

  defp validate_non_empty(string, field) do
    if String.trim(string) != "" do
      :ok
    else
      {:error, DomainError.new(:empty_value, "#{field_name(field)} cannot be empty", field)}
    end
  end

  defp validate_characters(string, field) do
    if String.match?(string, ~r/^[a-zA-Z0-9 ]+$/) do
      :ok
    else
      {:error,
       DomainError.new(
         :invalid_characters,
         "#{field_name(field)} contains invalid characters",
         field
       )}
    end
  end

  defp field_name(:name), do: "Name"
  defp field_name(:surname), do: "Surname"

  defp normalize_name(name) do
    name
    |> String.trim()
    |> String.downcase()
    |> String.split(" ")
    |> Enum.map(&String.capitalize/1)
    |> Enum.join(" ")
  end
end
