defmodule DomainError do
  defstruct [:code, :message, :http_error_code]

  def new(code, message, http_error_code \\ :unprocessable_entity) do
    %__MODULE__{code: code, message: message, http_error_code: http_error_code}
  end
end
