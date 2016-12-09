# xmart_things

> SmartThings OAuth2 Strategy and Client for Elixir

This was implemented while I followed [this](http://docs.smartthings.com/en/latest/smartapp-web-services-developers-guide/overview.html) but can be used for all the needs to build Web Services SmartApps with SmartThings.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

- Add `xmart_things` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [{:xmart_things, "~> 0.1.0"}]
end
```

- Ensure `xmart_things` is started before your application:

```elixir
def application do
  [applications: [:xmart_things]]
end
```

## Configuration

Add a configuration block as below in your configuration:

```elixir
config :xmart_things,
  client_id: System.get_env("ST_CLIENT_ID"),
  client_secret: System.get_env("ST_CLIENT_SECRET"),
  redirect_uri: System.get_env("ST_REDIRECT_URI"),
  scope: "app"
  # , app_uuid: "" # set this if you wish to explicitly specify site/smartapp base uri to call
```

## Usage

```elixir
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

# if you set `app_uuid` on your config, you don't need to update `site` in the `st_client` struct

XmartThings.get(st_client, "/locks")
```

## Author

- [techgaun](https://github.com/techgaun)
