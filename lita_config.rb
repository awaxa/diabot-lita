begin
  require 'pry'
rescue LoadError
end

Lita.configure do |config|
  options = {}
  options[:name] = 'diabot'
  options[:channels] = ['#reddit-diabetes-ops-debug']

  platform = :heroku if ENV['DYNO']
  case platform
  when :heroku
    options[:channels] << ['#reddit-diabetes', '#reddit-diabetes-ops']
    config.http.port   = ENV['PORT']
    config.redis[:url] = ENV['REDISCLOUD_URL']
  else
    config.redis[:url] = ENV['LITA_REDIS_URL'] || 'redis://127.0.0.1:6379/'
  end

  config.handlers.reddit.client_id     = ENV['LITA_REDDIT_CLIENT_ID'] || ''
  config.handlers.reddit.client_secret = ENV['LITA_REDDIT_CLIENT_SECRET'] || ''
  config.handlers.reddit.reddits = [
    { subreddit: 'diabetes', channel: '#reddit-diabetes-ops-debug' }
  ]

  config.handlers.keepalive.url = "http://#{options[:name]}.herokuapp.com"

  config.handlers.diabetes.lower_bg_bound = '20'
  config.handlers.diabetes.upper_bg_bound = '35'

  config.robot.name = options[:name]
  config.robot.locale = :en
  config.robot.log_level = :debug
  config.robot.adapter = :irc
  config.adapters.irc.server = 'irc.freenode.net'
  config.adapters.irc.channels = options[:channels].flatten
  config.adapters.irc.log_level = :debug
  config.adapters.irc.user = 'diabot'
  config.adapters.irc.realname = options[:name]
  config.adapters.irc.cinch = lambda do |cinch_config|
    cinch_config.sasl.username = 'diabot'
    if ENV['LITA_NICKSERV_PASSWORD']
      cinch_config.sasl.password = ENV['LITA_NICKSERV_PASSWORD']
    end
    cinch_config.max_reconnect_delay = 123
    cinch_config.port = '6697'
    cinch_config.ssl.use = true
  end
end
