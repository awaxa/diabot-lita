begin
  require 'pry'
rescue LoadError
end

Lita.configure do |config|

  options = {}
  options[:name] = "diabot"
  options[:channels] = [ "##diabot" ]

  platform = :boxen  if ENV["BOXEN_SETUP_VERSION"]
  platform = :heroku if ENV["DYNO"]
  case platform
  when :heroku
    options[:channels] = [ "#reddit-diabetes" , "#reddit-diabetes-ops" ]
    config.http.port   = ENV["PORT"]
    config.redis[:url] = ENV["REDISCLOUD_URL"]
  when :boxen
    config.redis[:url] = ENV["BOXEN_REDIS_URL"]
  else
    config.redis[:url] = ENV["LITA_REDIS_URL"] || "redis://127.0.0.1:6379/"
  end

  config.handlers.reddit.client_id     = ENV["LITA_REDDIT_CLIENT_ID"] || ""
  config.handlers.reddit.client_secret = ENV["LITA_REDDIT_CLIENT_SECRET"] || ""
  config.handlers.reddit.reddits = [
    { subreddit: "diabetes", channel: "#reddit-diabetes" },
  ]

  config.handlers.keepalive.url = "http://#{options[:name]}.herokuapp.com"

  config.robot.name = options[:name]
  config.robot.locale = :en
  config.robot.log_level = :debug
  config.robot.adapter = :irc
  config.adapters.irc.server = "irc.freenode.net"
  config.adapters.irc.channels = options[:channels]
  config.adapters.irc.log_level = :info
  if ENV["LITA_NICKSERV_PASSWORD"]
    config.adapters.irc.user = "diabot"
    config.adapters.irc.password = ENV["LITA_NICKSERV_PASSWORD"]
  end
  config.adapters.irc.realname = options[:name]
  config.adapters.irc.cinch = lambda do |cinch_config|
    cinch_config.max_reconnect_delay = 123
    cinch_config.port = "6697"
    cinch_config.ssl.use = true
  end

end
