if ENV.fetch("ELASTICSEARCH_URL") { "" }[/es\.amazonaws\.com/]
  Searchkick.aws_credentials = {
    region: ENV.fetch("AWS_DEFAULT_REGION") { "eu-central-1" },
    credentials_provider: Aws::CredentialProviderChain.new.resolve
  }
end
Searchkick.index_suffix = ENV["REVIEW_APP_NAME"]
Searchkick.redis = ConnectionPool.new { Redis.new }
