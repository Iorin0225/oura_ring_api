# OuraRingApi

Oura API V2用 Ruby client。Oura API V1とPersonal Access Tokenは対応外。

## Installation

```ruby
gem "oura_ring_api"
```

Ruby 3.4.8以上が必要。

## OAuth 2.0

Oura CloudでOAuth applicationを登録し、登録済みのredirect URIを指定する。

```ruby
client = OuraRingApi::Client.new(
  client_id: ENV.fetch("OURA_CLIENT_ID"),
  client_secret: ENV.fetch("OURA_CLIENT_SECRET"),
  redirect_uri: "https://example.com/oura/callback"
)

redirect_to client.authorization_url(state: csrf_token)
```

`state`はアプリケーション側でランダム生成し、callbackで検証する。

```ruby
token_info = client.authenticate(code: params[:code])
# token_infoを安全な永続ストアへ保存する。refresh tokenは更新ごとに置換する。

client = OuraRingApi::Client.new(
  client_id: ENV.fetch("OURA_CLIENT_ID"),
  client_secret: ENV.fetch("OURA_CLIENT_SECRET"),
  redirect_uri: "https://example.com/oura/callback",
  token_info: token_info
)
```

トークンを自動refreshした後は、`client.token_info` を再保存する。

デフォルトscopeは`email personal daily workout tag session`。必要に応じて`scopes:`へ配列を渡す。

## Data

利用可能なV2 endpoint: `personal_info`、`daily_sleep`、`sleep`、`daily_activity`、`daily_readiness`、`session`、`tag`、`workout`。

```ruby
page = client.daily_activity("2026-01-01", "2026-01-31", fields: "steps")
page.records.each { |record| puts record.steps }

client.each_page(:daily_activity, start_date: "2026-01-01") do |response|
  response.records.each { |record| puts record.steps }
end

sleep = client.sleep(document_id: "sleep-document-id")
```

list endpointは`next_token:`と`fields:`を受け取る。`each_page`は明示的に全pageを列挙する。

非2xx responseは`OuraRingApi::HttpError`をraiseする。`status`、`body`、`headers`を参照できる。429の自動retryは行わない。

## Development

```sh
bundle _2.6.9_ install
bundle _2.6.9_ exec rspec
```
