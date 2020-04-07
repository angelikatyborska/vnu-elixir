defmodule Vnu.Error do
  defstruct reason: nil, message: nil

  @reasons [:unexpected_server_response, :invalid_config]

  @type t :: %__MODULE__{
          reason: :unexpected_server_response | :invalid_config,
          message: String.t()
        }

  @spec new(atom(), String.t()) :: t()
  def new(reason, message) when reason in @reasons and is_bitstring(message) do
    %__MODULE__{reason: reason, message: message}
  end
end
