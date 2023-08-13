defmodule PhoenixAppWeb.VnuMintClient do
  @behaviour Vnu.HTTPClient

  @impl true
  def post(url, body, headers) do
    uri = URI.parse(url)

    {:ok, conn} =
      Mint.HTTP.connect(if(uri.scheme == "https", do: :https, else: :http), uri.host, uri.port)

    {:ok, conn, request_ref} =
      Mint.HTTP.request(conn, "POST", uri.path <> "?" <> uri.query, headers, body)

    case get_responses(conn, request_ref) do
      {:error, error} ->
        {:error, error}

      {:ok, responses} ->
        {:status, _, status} =
          Enum.find(responses, fn response ->
            elem(response, 0) == :status && elem(response, 1) == request_ref
          end)

        body =
          responses
          |> Enum.filter(fn response ->
            elem(response, 0) == :data && elem(response, 1) == request_ref
          end)
          |> Enum.map(&elem(&1, 2))
          |> Enum.join("")

        {:ok, %{status: status, body: body}}
    end
  end

  defp get_responses(conn, request_ref, acc \\ []) do
    receive do
      message ->
        case Mint.HTTP.stream(conn, message) do
          {:error, _, error, _} ->
            {:error, error}

          {:ok, conn2, responses} ->
            if Enum.any?(responses, fn response ->
                 elem(response, 0) == :done && elem(response, 1) == request_ref
               end) do
              {:ok, Enum.reverse(Enum.reverse(responses) ++ acc)}
            else
              get_responses(conn2, request_ref, Enum.reverse(responses) ++ acc)
            end

          :unknown ->
            get_responses(conn, request_ref)
        end
    end
  end
end
