Lita.configure do |config|

  options = {
    :name => ENV["LITA_NAME"] || "diabot",
    :channels => ENV["LITA_CHANNELS"] || "##diabot",
  }

  # The name your robot will use.
  config.robot.name = options[:name]

  # The locale code for the language to use.
  config.robot.locale = :en

  # The severity of messages to log. Options are:
  # :debug, :info, :warn, :error, :fatal
  # Messages at the selected level and above will be logged.
  config.robot.log_level = :debug

  # An array of user IDs that are considered administrators. These users
  # the ability to add and remove other users from authorization groups.
  # What is considered a user ID will change depending on which adapter you use.
  # config.robot.admins = ["1", "2"]

  # The adapter you want to connect with. Make sure you've added the
  # appropriate gem to the Gemfile.
  config.robot.adapter = :irc
  config.adapters.irc.server = "irc.freenode.net"
  config.adapters.irc.channels = options[:channels].split(',')
  config.adapters.irc.log_level = :debug
  config.adapters.irc.cinch = lambda do |cinch_config|
    cinch_config.max_reconnect_delay = 123
    cinch_config.port = "6697"
    cinch_config.ssl.use = true
  end

  ## Example: Set options for the chosen adapter.
  # config.adapter.username = "myname"
  # config.adapter.password = "secret"

  ## Example: Set options for the Redis connection.
  # config.redis.host = "127.0.0.1"
  # config.redis.port = 1234

  platform = :heroku if ENV["DYNO"]
  platform = :boxen if ENV["BOXEN_SETUP_VERSION"]
  case platform
  when :heroku
    config.http.port = ENV["PORT"]
    config.redis[:url] = ENV["REDISTOGO_URL"]
  when :boxen
    config.redis[:url] = ENV["BOXEN_REDIS_URL"]
  else
    config.redis[:url] = ENV["LITA_REDIS_URL"] || "redis://127.0.0.1:6379/"
  end

  ## Example: Set configuration for any loaded handlers. See the handler's
  ## documentation for options.
  # config.handlers.some_handler.some_config_key = "value"
end
