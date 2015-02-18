begin
  require 'pry'
rescue LoadError
end

Lita.configure do |config|

  options = {
    :name                 => ENV["LITA_NAME"] || "diabot",
    :channels             => ENV["LITA_CHANNELS"] || "##diabot",
    :admins               => ENV["LITA_ADMINS"] || "",
    :nickserv_password    => ENV["LITA_NICKSERV_PASSWORD"] || "",
    :reddit_client_id     => ENV["LITA_REDDIT_CLIENT_ID"] || "",
    :reddit_client_secret => ENV["LITA_REDDIT_CLIENT_SECRET"] || "",
  }

  config.robot.name = options[:name]

  config.robot.locale = :en

  config.robot.log_level = :debug

  config.robot.admins = options[:admins].split(',') unless options[:admins].empty?

  config.robot.adapter = :irc
  config.adapters.irc.server = "irc.freenode.net"
  config.adapters.irc.channels = options[:channels].split(",")
  config.adapters.irc.log_level = :debug
  config.adapters.irc.user = options[:name]
  config.adapters.irc.password = options[:nickserv_password] unless options[:nickserv_password].empty?
  config.adapters.irc.realname = options[:name]
  config.adapters.irc.cinch = lambda do |cinch_config|
    cinch_config.max_reconnect_delay = 123
    cinch_config.port = "6697"
    cinch_config.ssl.use = true
  end

  config.handlers.keepalive.url = "http://#{options[:name]}.herokuapp.com"

  config.handlers.reddit.client_id = options[:reddit_client_id]
  config.handlers.reddit.client_secret = options[:reddit_client_secret]
  config.handlers.reddit.reddits = []

  platform = :boxen  if ENV["BOXEN_SETUP_VERSION"]
  platform = :heroku if ENV["DYNO"]
  case platform
  when :heroku
    config.http.port = ENV["PORT"]
    config.redis[:url] = ENV["REDISCLOUD_URL"]
    config.handlers.reddit.reddits << { subreddit: "diabetes", channel: "#reddit-diabetes" }
  when :boxen
    config.redis[:url] = ENV["BOXEN_REDIS_URL"]
  else
    config.redis[:url] = ENV["LITA_REDIS_URL"] || "redis://127.0.0.1:6379/"
  end

end
