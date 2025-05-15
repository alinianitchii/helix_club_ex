defmodule People.Domain.BirthDateValueObject do
  defstruct [:value]

  def new(date_of_birth) do
    {:ok, %__MODULE__{value: date_of_birth}}
  end
end
