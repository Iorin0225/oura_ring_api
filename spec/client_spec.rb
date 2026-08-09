# frozen_string_literal: true

RSpec.describe OuraRingApi::Client do
  let(:token_info) do
    { access_token: "access-token", refresh_token: "refresh-token", expires_at: Time.now.to_i + 3600 }
  end

  let(:client) do
    described_class.new(
      client_id: "client-id",
      client_secret: "client-secret",
      redirect_uri: "https://example.test/callback",
      token_info: token_info
    )
  end

  let(:faraday_api) do
    lambda do |&setup_stubs|
      Faraday.new(url: "https://api.ouraring.com") do |faraday|
        faraday.request :authorization, :Bearer, "access-token"
        faraday.response :json, content_type: /\bjson$/
        faraday.adapter :test, Faraday::Adapter::Test::Stubs.new(&setup_stubs)
      end
    end
  end

  it "generates an encoded authorization URL with the requested state" do
    url = client.authorization_url(state: "csrf state")

    expect(url).to include("redirect_uri=https%3A%2F%2Fexample.test%2Fcallback")
    expect(url).to include("state=csrf+state")
    expect(url).to include("scope=email+personal+daily+workout+tag+session")
  end

  it "accepts legacy timestamp strings and exposes normalized token information" do
    legacy_client = described_class.new(
      client_id: "client-id",
      client_secret: "client-secret",
      redirect_uri: "https://example.test/callback",
      token_info: token_info.merge(expires_at: "2026-01-01 00:00:00")
    )

    expect(legacy_client.token_info[:expires_at]).to eq(Time.parse("2026-01-01 00:00:00").to_i)
  end

  it "sends V2 collection query parameters and parses the next page token" do
    api = faraday_api.call do |stubs|
      stubs.get("/v2/usercollection/daily_activity") do |env|
        expect(env.request_headers["Authorization"]).to eq("Bearer access-token")
        expect(env.url.query).to include("start_date=2026-01-01")
        expect(env.url.query).to include("fields=steps")
        [200, { "Content-Type" => "application/json" }, '{"data":[{"day":"2026-01-01","steps":10}],"next_token":"cursor"}']
      end
    end
    allow(client).to receive(:api_client).and_return(api)

    response = client.daily_activity("2026-01-01", nil, fields: "steps")

    expect(response.records.first.steps).to eq(10)
    expect(response.next_token).to eq("cursor")
  end

  it "supports a single sleep document" do
    api = faraday_api.call do |stubs|
      stubs.get("/v2/usercollection/sleep/sleep-id") { [200, { "Content-Type" => "application/json" }, '{"id":"sleep-id"}'] }
    end
    allow(client).to receive(:api_client).and_return(api)

    expect(client.sleep(document_id: "sleep-id").records.first.id).to eq("sleep-id")
  end

  it "raises HttpError for non-success responses" do
    api = faraday_api.call do |stubs|
      stubs.get("/v2/usercollection/tag") { [429, { "Content-Type" => "application/json", "Retry-After" => "60" }, '{"status":429,"title":"Too Many Requests"}'] }
    end
    allow(client).to receive(:api_client).and_return(api)

    expect { client.tag }.to raise_error(OuraRingApi::HttpError) { |error|
      expect(error.status).to eq(429)
      expect(error.headers["Retry-After"]).to eq("60")
    }
  end

  it "exposes every supported V2 collection" do
    paths = {
      personal_info: "/v2/usercollection/personal_info",
      daily_sleep: "/v2/usercollection/daily_sleep",
      sleep: "/v2/usercollection/sleep",
      daily_activity: "/v2/usercollection/daily_activity",
      daily_readiness: "/v2/usercollection/daily_readiness",
      session: "/v2/usercollection/session",
      tag: "/v2/usercollection/tag",
      workout: "/v2/usercollection/workout"
    }
    api = faraday_api.call do |stubs|
      paths.each_value do |path|
        stubs.get(path) { [200, { "Content-Type" => "application/json" }, '{"data":[]}'] }
      end
    end
    allow(client).to receive(:api_client).and_return(api)

    paths.each_key { |method| expect(client.public_send(method)).to be_a(OuraRingApi::Response::Base) }
  end
end
