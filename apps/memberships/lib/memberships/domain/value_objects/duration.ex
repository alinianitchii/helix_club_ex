defmodule Memberships.Domain.DurationValueObject do
  defstruct [:type, :start_date, :end_date]

  # TODO test and write the correct implementation
  def new(type, start_date) do
    {:ok,
     %__MODULE__{
       type: type,
       start_date: start_date,
       end_date: ~D[2026-05-31]
     }}
  end
end
