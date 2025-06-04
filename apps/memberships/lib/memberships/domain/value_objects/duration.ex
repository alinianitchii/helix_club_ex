defmodule Memberships.Domain.DurationValueObject do
  alias Memberships.Domain.MembershipTypes

  defstruct [:type, :start_date, :end_date]

  @valid_types MembershipTypes.all()

  def new(_type, start_date) when not is_struct(start_date, Date),
    do: {:error, DomainError.new(:invalid_date, "Invalid start date")}

  def new(type, _start_date) when type not in @valid_types,
    do: {:error, DomainError.new(:invalid_type, "Invalid duration type")}

  def new(type, start_date) do
    end_date = add_months_to_date(start_date, MembershipTypes.type_duration(type))

    {:ok,
     %__MODULE__{
       type: type,
       start_date: start_date,
       end_date: end_date
     }}
  end

  defp add_months_to_date(%Date{year: year, month: month, day: day}, months_to_add) do
    total_months = year * 12 + month - 1 + months_to_add

    new_year = div(total_months, 12)
    new_month = rem(total_months, 12) + 1

    case Date.new(new_year, new_month, day) do
      {:ok, date} ->
        Date.add(date, -1)

      {:error, :invalid_date} ->
        last_day = Date.days_in_month(%Date{year: new_year, month: new_month, day: 1})
        {:ok, fallback_date} = Date.new(new_year, new_month, last_day)
        fallback_date
    end
  end
end
