defmodule Vnu.Response do
  defstruct messages: []

  alias Vnu.Message

  @type t :: %__MODULE__{
          messages: list(Message.t())
        }
end
