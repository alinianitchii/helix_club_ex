defmodule Memberships.Domain.MembershipTypes do
  @moduledoc """
  Defines allowed membership type kinds.
  """

  @types [:yearly, :quarterly, :monthly]
  @type_months %{
    yearly: 12,
    quarterly: 4,
    monthly: 1
  }

  def all, do: @types

  def type_duration(type) do
    Map.fetch!(@type_months, type)
  end

  def valid?(type), do: type in @types
end
