#!/usr/bin/env ruby
# frozen_string_literal: true

$stdout.sync = true

require 'yaml'
require 'open-uri'

require 'rubygems'
require 'bundler/setup'
Bundler.require(:default)

@config = YAML.load_file('config.yml')

bot = Discordrb::Bot.new(
  token: @config['token'],
  type: @config['type'],
  parse_self: false
)

bot.run(true)

puts "Logged in as: #{bot.profile.distinct}"
puts "Servers: #{bot.servers.count}"
puts "Total Emoji: #{bot.emojis.count}"

Dir.mkdir('output') unless File.exist?('output')

bot.servers.each do |_id, server|
  if server.emojis.count.zero? || server.emojis.nil?
    puts "Server '#{server.name}' has no emoji, skipping..."
    next
  else
    Dir.mkdir("output/#{server.name}_#{server.id}") unless File.exist?("output/#{server.name}_#{server.id}")
    puts "Downloading emoji from '#{server.name}'..."
    server.emojis.each do |id, emoji|
      if emoji.animated
        url = "https://cdn.discordapp.com/emojis/#{id}.gif"
        unless File.exist?("output/#{server.name}_#{server.id}/animated/")
          Dir.mkdir("output/#{server.name}_#{server.id}/animated")
        end
        Thread.new do
          IO.copy_stream(OpenURI.open_uri(url),
                         "output/#{server.name}_#{server.id}/animated/#{emoji.name}_#{emoji.id}.gif")
        end
      else
        url = "https://cdn.discordapp.com/emojis/#{id}.png"
        unless File.exist?("output/#{server.name}_#{server.id}/static/")
          Dir.mkdir("output/#{server.name}_#{server.id}/static")
        end
        Thread.new do
          IO.copy_stream(OpenURI.open_uri(url),
                         "output/#{server.name}_#{server.id}/static/#{emoji.name}_#{emoji.id}.png")
        end
      end
    end
  end
end

puts 'All done here! You can find your emojis in the "output" folder!'
# TODO: Fix this
puts 'Note: Because I\'m lazy, you will have to rename/delete the output folder before running this again,'\
     'or weird things happen.'
