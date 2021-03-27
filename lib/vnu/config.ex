defmodule Vnu.Config do
  @moduledoc false

  alias Vnu.Error

  defstruct [:http_client, :server_url, :format, :filter]

  @defaults [
    http_client: Vnu.HTTPClient.Hackney,
    server_url: "http://localhost:8888",
    format: :html,
    filter: nil
  ]

  @doc false
  def new(opts) when is_list(opts) do
    opts = Keyword.merge(@defaults, opts)

    %__MODULE__{}
    |> set_http_client(opts)
    |> set_server_url(opts)
    |> set_format(opts)
    |> set_filter(opts)
  end

  @doc false
  def new!(opts) when is_list(opts) do
    case new(opts) do
      {:ok, config} -> config
      {:error, error} -> raise inspect(error)
    end
  end

  defp set_http_client(config, opts) do
    http_client = Keyword.get(opts, :http_client)

    cond do
      !is_atom(http_client) ->
        {:error,
         Error.new(
           :invalid_config,
           "Expected http_client to be a module, got: #{inspect(http_client)}"
         )}

      !Code.ensure_loaded?(http_client) || !Kernel.function_exported?(http_client, :post, 3) ->
        {:error,
         Error.new(
           :invalid_config,
           "Expected http_client to be a module that implements the Vnu.HTTPClient behaviour, got: #{
             inspect(http_client)
           }"
         )}

      true ->
        {:ok, %{config | http_client: http_client}}
    end
  end

  defp set_server_url({:error, error}, _opts), do: {:error, error}

  defp set_server_url({:ok, config}, opts) do
    server_url = Keyword.get(opts, :server_url)

    if is_bitstring(server_url) do
      server_url = if String.ends_with?(server_url, "/"), do: server_url, else: server_url <> "/"
      {:ok, %{config | server_url: server_url}}
    else
      {:error,
       Error.new(
         :invalid_config,
         "Expected server_url to be a string, got: #{inspect(server_url)}"
       )}
    end
  end

  @formats [:html, :css, :svg]
  defp set_format({:error, error}, _opts), do: {:error, error}

  defp set_format({:ok, config}, opts) do
    format = Keyword.get(opts, :format)

    if format in [:html, :css, :svg] do
      {:ok, %{config | format: format}}
    else
      {:error,
       Error.new(
         :invalid_config,
         "Expected format to be one of #{Enum.map(@formats, &Kernel.inspect/1) |> Enum.join(", ")}, got: #{
           inspect(format)
         }"
       )}
    end
  end

  defp set_filter({:error, error}, _opts), do: {:error, error}

  defp set_filter({:ok, config}, opts) do
    filter = Keyword.get(opts, :filter)

    if is_atom(filter) and is_function(&filter.exclude_message?/1) do
      {:ok, %{config | filter: filter}}
    else
      {:error,
       Error.new(
         :invalid_config,
         "Expected filter to be a module that implements the Vnu.MessageFilter behavior, got: #{
           inspect(filter)
         }"
       )}
    end
  end
end
