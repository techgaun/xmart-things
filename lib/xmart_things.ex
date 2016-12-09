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

      case XmartThings.get(st_client, "/locks") do
        {:ok, %OAuth2.Response{status_code: 401, body: body}} ->
          {:error, "unauthorized token"}
        {:ok, %OAuth2.Response{status_code: status_code, body: locks}} when status_code in [200..399] ->
          locks
        {:error, %OAuth2.Error{reason: reason}} ->
          {:error, reason}
      end
  """

  alias OAuth2.Strategy.AuthCode
  use OAuth2.Strategy

  @endpoint_uri "https://graph.api.smartthings.com/api/smartapps/endpoints"

  def client do
    OAuth2.Client.new([
      strategy: __MODULE__,
      client_id: client_id,
      client_secret: client_secret,
      redirect_uri: redirect_uri,
      site: "https://graph.api.smartthings.com",
      authorize_url: "https://graph.api.smartthings.com/oauth/authorize",
      token_url: "https://graph.api.smartthings.com/oauth/token"
    ])
  end

  def authorize_url! do
    OAuth2.Client.authorize_url!(client, scope: scope)
  end

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

  def endpoints(client), do: client |> __MODULE__.get(@endpoint_uri)
  def endpoints!(client), do: client |> __MODULE__.get!(@endpoint_uri)

  defdelegate get!(client, endpoint), to: OAuth2.Client
  defdelegate get!(client, endpoint, headers), to: OAuth2.Client
  defdelegate get!(client, endpoint, headers, params), to: OAuth2.Client
  defdelegate get(client, endpoint), to: OAuth2.Client
  defdelegate get(client, endpoint, headers), to: OAuth2.Client
  defdelegate get(client, endpoint, headers, params), to: OAuth2.Client

  defp client_id, do: Application.get_env(:xmart_things, :client_id)
  defp client_secret, do: Application.get_env(:xmart_things, :client_secret)
  defp redirect_uri, do: Application.get_env(:xmart_things, :redirect_uri)
  defp display_link, do: Application.get_env(:xmart_things, :display_link)
  defp display_name, do: Application.get_env(:xmart_things, :display_name)
  defp scope, do: Application.get_env(:xmart_things, :scope) || "app"
end
