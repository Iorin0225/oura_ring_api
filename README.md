# OuraRingApi

This gem handles communicating with Oura Cloud API, the API service with OuraRing!

If you want to know more detail, see this: https://cloud.ouraring.com/docs

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'oura_ring_api'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install oura_ring_api

## Usage

This gem has 2 ways to use.

### Personal Access Token (for development)

This is really simple and easy to use, but it's only for development

#### 1. Create you Personal Access Token on Oura Cloud.

Access here: https://cloud.ouraring.com/personal-access-tokens

#### 2. Set the token to the client class

```rb
client = OuraRingApi::Client.new(personal_access_token: your_token)
client.userinfo.body # This would work
```

### OAuth2 Flow

Oura Cloud requires us to use OAuth2 Authentication flow for third party app.

#### 1. Register your application on Oura Cloud.

Access here: https://cloud.ouraring.com/oauth/applications

(At now, please use "http://localhost:8080" for redirect url. It's just WIP :bow: )

After you register your application, you will get Client ID and Client Secret.

#### 2. Set Client ID and Client Secret to the client class

```rb
client = OuraRingApi::Client.new(client_id: your_id, client_secret: your_secret)
```

#### 3. Get an access_token

The client class generate an url to generate access token.

```rb
 client.url_to_generate_code
=> "https://cloud.ouraring.com/oauth/authorize?client_id=******&redirect_uri=http://localhost:8080&response_type=code"
```

Access the URL and then please "Acceppt". 

After that, you'll be redirected to the URL like `http://localhost:8080/?code=***&scope=email%20personal%20daily`. So please copy the code on the URL.

#### 4. Set the code to the client

```rb
client.authenticate(code: '****')
=> {:access_token=>"****", :refresh_token=>"****", :expires_at=>"2021-10-30 17:05:18"}

client.userinfo.body # This would work
```

#### 5. Initialize the client with the result of Oauth2

You can re-use the result of OAuth2by 

```rb
your_token_info = {:access_token=>"****", :refresh_token=>"****", :expires_at=>"2021-10-30 17:05:18"}
client = OuraRingApi::Client.new(token_info: your_token_info)

client.userinfo.body # This would work
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/oura_ring_api. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/[USERNAME]/oura_ring_api/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the OuraRingApi project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/oura_ring_api/blob/master/CODE_OF_CONDUCT.md).
