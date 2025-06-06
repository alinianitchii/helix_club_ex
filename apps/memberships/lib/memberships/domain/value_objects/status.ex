defmodule Memberships.Domain.StatusValueObject do
  defstruct [:status]

  @valid_statuses [:pending, :activated, :suspended, :archived, :canceled]
  def new(), do: {:ok, %__MODULE__{status: :pending}}

  # enable piping
  def change({:ok, %__MODULE__{} = vo}, new_status), do: change(vo, new_status)
  def change({:error, _} = error, _new_status), do: error

  def change(%__MODULE__{status: current}, new_status) do
    state_transition(current, new_status)
  end

  defp state_transition(_, new_status) when new_status not in @valid_statuses do
    {:error, DomainError.new(:invalid_value, "Invalid membership status value")}
  end

  defp state_transition(:pending, :suspended) do
    {:error,
     DomainError.new(:invalid_state, "Invalid state transition from pending to suspended")}
  end

  defp state_transition(_, :pending) do
    {:error, DomainError.new(:invalid_state, "Invalid state transition to pending")}
  end

  defp state_transition(:cancelled, _) do
    {:error, DomainError.new(:invalid_state, "Invalid state transition from cancelled")}
  end

  defp state_transition(_, new_status), do: {:ok, %__MODULE__{status: new_status}}
end
