defmodule Vnu.Error do
  @moduledoc "An error holds details about why validating a given document could not be finished."

  defexception reason: nil, message: nil

  @reasons [:unexpected_server_response, :invalid_config]

  @type t :: %__MODULE__{
          reason: :unexpected_server_response | :invalid_config,
          message: String.t()
        }

  @doc false
  def new(reason, message) when reason in @reasons and is_bitstring(message) do
    %__MODULE__{reason: reason, message: message}
  end
end
