if Rails.env.production?
  uri = URI.parse(ENV['REDISTOGO_URL'])
  Resque.redis = Redis.new(host: uri.host,
                           port: uri.port,
                           password: uri.password)
else
  Resque.redis = 'localhost:6379'
end
