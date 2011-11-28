# -*- coding: utf-8 -*-
require "bundler/setup"

require "highline"
require "twitter"
require "escape_utils"

module Faraday
  module Utils
    def escape(s)
      EscapeUtils.escape_url(s.to_s)
    end
  end
end

conf = YAML.load_file("config.yml")

Twitter.configure do |config|
  config.consumer_key = conf["consumer_key"]
  config.consumer_secret = conf["consumer_secret"]
  config.oauth_token = conf["access_token"]
  config.oauth_token_secret = conf["access_token_secret"]
end

@login = false

def need_login
  if not @login
    puts "Please login using 'login' command first"
    return
  end
  yield
end

def print_tweet(t)
  puts "[#{t.created_at}] #{t.user.screen_name} >> #{t.text}"
end

ui = HighLine.new
while true
  @command = ui.ask("Twitter >>> ")
  case @command
  when /^tl/
    need_login do
      count = @command[/[0-9]+/].to_i
      count = 20 if not (1..200).include?(count)
      Twitter.home_timeline(:count => count).reverse.each {|t| print_tweet t}
    end
  when /^tw /
    need_login do
      text = @command.split(/^tw /)[1]
      Twitter.update(text)
    end
  when /^(mentions|m)/
    need_login do
      Twitter.mentions.reverse.each{|t| print_tweet t}
    end
  when /^(exit|q|quit)$/
    exit
  when /^(login|l)$/
    @login = true
    puts "#{Twitter.user.name} logged in."
  else
    puts "Unknown command."
  end
end
