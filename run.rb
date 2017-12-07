require 'discordrb'
require 'yaml'
require 'open-uri'

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

Dir.mkdir('output') unless File.exists?('output')

bot.servers.each {|id,server|
  if server.emojis.count.zero? || server.emojis.nil?
    puts "Server '#{server.name}' has no emoji, skipping..."
    next
  else
    Dir.mkdir("output/#{server.name}_#{server.id}") unless File.exists?("output/#{server.name}_#{server.id}")
    puts "Downloading emoji from '#{server.name}'..."
    server.emojis.each { |id, emoji|
      url = "https://cdn.discordapp.com/emojis/#{id}.png"
      IO.copy_stream(open(url), "output/#{server.name}_#{server.id}/#{emoji.name}.png")
    }
  end
}

puts 'All done here! You can find your emojis in the "output" folder!']
#TODO Fix this
puts 'Note: Because I\'m lazy, you will have to rename/delete the output folder before running this again, or weird things happen.'