Tumblr.configure do |config|
  config.consumer_key = Settings.tumblr.consumer_key
  config.consumer_secret = Settings.tumblr.consumer_secret
  config.oauth_token = Settings.tumblr.oauth_token
  config.oauth_token_secret = Settings.tumblr.oauth_token_secret
end