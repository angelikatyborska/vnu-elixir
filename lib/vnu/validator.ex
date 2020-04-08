defmodule Vnu.Validator do
  @moduledoc false

  alias Vnu.{Config, HTTP, Error, Result}

  @doc false
  def valid?(%Result{messages: messages}, opts \\ []) do
    warnings_as_errors = Keyword.get(opts, :warnings_as_errors, false)

    Enum.all?(messages, fn message ->
      message.type == :info && (warnings_as_errors == false || message.sub_type != :warning)
    end)
  end

  @doc false
  def validate(string, opts) do
    with {:ok, config} <- Config.new(opts),
         {:ok, %Result{} = response} <- HTTP.get_result(string, config),
         {:ok, response} <- check_if_result_is_determinate(response) do
      {:ok, response}
    else
      error -> error
    end
  end

  defp check_if_result_is_determinate(response) do
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

  defp determine_outcome(%Result{} = response) do
    grouped_messages = Enum.group_by(response.messages, & &1.type)

    case grouped_messages do
      %{:non_document_error => list} when list != [] -> {:indeterminate, list}
      %{:error => list} when list != [] -> {:failure, list}
      _ -> :success
    end
  end
end
