defmodule Vnu.Validator do
  @moduledoc false

  alias Vnu.{Config, HTTP, Response, Error}

  @doc false
  def validate(string, opts) do
    with {:ok, config} <- Config.new(opts),
         {:ok, %Response{} = response} <- HTTP.get_response(string, config),
         {:ok, response} <- check_if_response_is_determinate(response) do
      {:ok, response}
    else
      error -> error
    end
  end

  defp check_if_response_is_determinate(response) do
    case determine_outcome(response) do
      {:indeterminate, list} ->
        {:error,
         %Error{
           reason: :unexpected_server_response,
           message:
             "The server could not finish validating the document, non-document errors occurred: #{
               inspect(list)
             }"
         }}

      _ ->
        {:ok, response}
    end
  end

  defp determine_outcome(%Response{} = response) do
    grouped_messages = Enum.group_by(response.messages, & &1.type)

    case grouped_messages do
      %{:non_document_error => list} when list != [] -> {:indeterminate, list}
      %{:error => list} when list != [] -> {:failure, list}
      _ -> :success
    end
  end
end
