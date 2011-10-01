#!/usr/bin/env ruby
$LOAD_PATH.unshift *Dir["#{File.dirname(__FILE__)}/lib"]

require 'yaml'
require 'getoptlong'

require 'rubygems'
require 'tweetstream'
require 'cinch'

require "join_part"
require 'tweet_stream'

opts = GetoptLong.new(
  ['--config', '-c', GetoptLong::OPTIONAL_ARGUMENT]
)

options = {}

config_filename = File.dirname(__FILE__) + '/config.yaml'

opts.each do |opt, arg|
  case opt
    when '--config'
      config_filename = arg
  end
end

if File.exists?(config_filename)
  options = YAML.load_file(config_filename)
else
  puts "No configuration found"
  exit 1
end

TweetStream.configure do |config|
  config.consumer_key = options['consumer_key']
  config.consumer_secret = options['consumer_secret']
  config.oauth_token = options['oauth_token']
  config.oauth_token_secret = options['oauth_token_secret']
end

bot = Cinch::Bot.new do
  configure do |c|
    c.server = options['irc_server']
    c.nick = options['nicks'].first
    c.nicks = options['nicks']
    c.channels = options['channels']

    c.plugins.plugins = [JoinPart]
    c.plugins.options[JoinPart][:admins] = options['admins']
  end
end

tweet_stream = Thread.new { TweetStreamThread.new(bot).start }

trap("INT") do
  tweet_stream.exit
  bot.quit "Bot has been killed."
end

bot.start
