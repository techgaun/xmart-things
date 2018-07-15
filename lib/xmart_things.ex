defmodule XmartThings do
  @moduledoc """
  OAuth Strategy module to work with SmartThings Web Services API

  ## Examples

      # Generate the authorization to redirect client for authorization
      XmartThings.authorize_url!

      # Capture the `code` from redirect in your callback handler route
      st_client = XmartThings.get_token!(code: code)

      # Use the access token to access resources

      locks = XmartThings.get!(st_client, "/locks").body

      # or
      case XmartThings.get(st_client, "/locks") do
        {:ok, %OAuth2.Response{status_code: 401, body: body}} ->
          {:error, "unauthorized token"}
        {:ok, %OAuth2.Response{status_code: status_code, body: locks}} when status_code in [200..399] ->
          locks
        {:error, %OAuth2.Error{reason: reason}} ->
          {:error, reason}
      end

      # Use `endpoints/1` or `endpoints!/1` to get the list of endpoints that you can use to talk with SmartApp
      XmartThings.endpoints!(st_client)

      # It can return bunch of responses. Pick one of those (usually the first one) to perform your requests to SmartApp

      [%{"uri" => uri} | _] = XmartThings.endpoints!(st_client).body

      # and now send the requests to URLs like below:

      XmartThings.get(%{st_client | site: uri}, "/locks")
  """

  alias OAuth2.Strategy.AuthCode
  use OAuth2.Strategy

  @endpoint_uri "https://graph.api.smartthings.com/api/smartapps/endpoints"
  @default_site "https://graph.api.smartthings.com"

  @doc """
  Creates a OAuth client struct for SmartThings Authorization
  """
  def client do
    OAuth2.Client.new(
      strategy: __MODULE__,
      client_id: client_id(),
      client_secret: client_secret(),
      redirect_uri: redirect_uri(),
      site: site(),
      authorize_url: "https://graph.api.smartthings.com/oauth/authorize",
      token_url: "https://graph.api.smartthings.com/oauth/token"
    )
  end

  @doc """
  Creates authorization URL based on the `client` configuration
  """
  def authorize_url! do
    OAuth2.Client.authorize_url!(client(), scope: scope())
  end

  @doc """
  Fetches an OAuth2.AccessToken struct by making a request to the token endpoint.
  """
  def get_token!(params \\ [], headers \\ [], opts \\ []) do
    OAuth2.Client.get_token!(client(), params, headers, opts)
  end

  def authorize_url(client, params) do
    AuthCode.authorize_url(client, params)
  end

  def get_token(client, params, headers) do
    client
    |> put_param(:client_secret, client.client_secret)
    |> put_header("accept", "application/json")
    |> AuthCode.get_token(params, headers)
  end

  @doc """
  Retrieve the lists of endpoints exposed for a SmartApp
  """
  def endpoints(client), do: client |> __MODULE__.get(@endpoint_uri)

  @doc """
  same as endpoints/1 but raises error

  ## Example getting URI for further requests
      [%{"uri" => uri} | _] = XmartThings.endpoints!(st_client).body
  """
  def endpoints!(client), do: client |> __MODULE__.get!(@endpoint_uri)

  @doc """
  Use these to send GET requests to the endpoints via `OAuth2.Client`.
  """
  defdelegate get!(client, endpoint), to: OAuth2.Client
  defdelegate get!(client, endpoint, headers), to: OAuth2.Client
  defdelegate get!(client, endpoint, headers, params), to: OAuth2.Client
  defdelegate get(client, endpoint), to: OAuth2.Client
  defdelegate get(client, endpoint, headers), to: OAuth2.Client
  defdelegate get(client, endpoint, headers, params), to: OAuth2.Client

  @doc """
  Use these to send PUT requests to the endpoints via `OAuth2.Client`.
  """
  defdelegate put!(client, endpoint), to: OAuth2.Client
  defdelegate put!(client, endpoint, body), to: OAuth2.Client
  defdelegate put!(client, endpoint, body, headers), to: OAuth2.Client
  defdelegate put!(client, endpoint, body, headers, opts), to: OAuth2.Client
  defdelegate put(client, endpoint), to: OAuth2.Client
  defdelegate put(client, endpoint, body), to: OAuth2.Client
  defdelegate put(client, endpoint, body, headers), to: OAuth2.Client
  defdelegate put(client, endpoint, body, headers, opts), to: OAuth2.Client

  @doc """
  Use these to send POST requests to the endpoints via `OAuth2.Client`.
  """
  defdelegate post!(client, endpoint), to: OAuth2.Client
  defdelegate post!(client, endpoint, body), to: OAuth2.Client
  defdelegate post!(client, endpoint, body, headers), to: OAuth2.Client
  defdelegate post!(client, endpoint, body, headers, opts), to: OAuth2.Client
  defdelegate post(client, endpoint), to: OAuth2.Client
  defdelegate post(client, endpoint, body), to: OAuth2.Client
  defdelegate post(client, endpoint, body, headers), to: OAuth2.Client
  defdelegate post(client, endpoint, body, headers, opts), to: OAuth2.Client

  @doc """
  Use these to send DELETE requests to the endpoints via `OAuth2.Client`.
  """
  defdelegate delete!(client, endpoint), to: OAuth2.Client
  defdelegate delete!(client, endpoint, body), to: OAuth2.Client
  defdelegate delete!(client, endpoint, body, headers), to: OAuth2.Client
  defdelegate delete!(client, endpoint, body, headers, opts), to: OAuth2.Client
  defdelegate delete(client, endpoint), to: OAuth2.Client
  defdelegate delete(client, endpoint, body), to: OAuth2.Client
  defdelegate delete(client, endpoint, body, headers), to: OAuth2.Client
  defdelegate delete(client, endpoint, body, headers, opts), to: OAuth2.Client

  defp client_id, do: Application.get_env(:xmart_things, :client_id)
  defp client_secret, do: Application.get_env(:xmart_things, :client_secret)
  defp redirect_uri, do: Application.get_env(:xmart_things, :redirect_uri)
  defp scope, do: Application.get_env(:xmart_things, :scope) || "app"
  defp site, do: :xmart_things |> Application.get_env(:app_uuid) |> _site

  defp _site(uuid) when is_binary(uuid),
    do: @default_site <> "/api/smartapps/installations/" <> uuid

  defp _site(_), do: @default_site
end
