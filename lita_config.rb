begin
  require 'pry'
rescue LoadError
end

Lita.configure do |config|

  options = {
    :name     => ENV["LITA_NAME"] || "diabot",
    :channels => ENV["LITA_CHANNELS"] || "##diabot",
    :admins   => ENV["LITA_ADMINS"] || "",
    :password => ENV["LITA_NICKSERV_PASSWORD"] || "",
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
  config.adapters.irc.password = options[:password] unless options[:password].empty?
  config.adapters.irc.realname = options[:name]
  config.adapters.irc.cinch = lambda do |cinch_config|
    cinch_config.max_reconnect_delay = 123
    cinch_config.port = "6697"
    cinch_config.ssl.use = true
  end

  platform = :heroku if ENV["DYNO"]
  platform = :boxen if ENV["BOXEN_SETUP_VERSION"]
  case platform
  when :heroku
    config.http.port = ENV["PORT"]
    config.redis[:url] = ENV["REDISCLOUD_URL"]
  when :boxen
    config.redis[:url] = ENV["BOXEN_REDIS_URL"]
  else
    config.redis[:url] = ENV["LITA_REDIS_URL"] || "redis://127.0.0.1:6379/"
  end

  config.handlers.keepalive.url = "http://#{options[:name]}.herokuapp.com"

end
