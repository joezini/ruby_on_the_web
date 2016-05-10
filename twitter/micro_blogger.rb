require 'jumpstart_auth'

class MicroBlogger
	attr_reader :client

	def initialize
		puts "Initializing..."
		@client = JumpstartAuth.twitter
	end

	def tweet(message)
		if message.length <= 140
			@client.update(message)
		else 
			puts "Tweet '#{message}' is too long!"
		end
	end

	def run
		puts "Welcome to the JSL Twitter Client!"
		command = ""
		while command != "q"
			printf "enter command: "
			input = gets.chomp
			parts = input.split(" ")
			command = parts[0]
			case command
			when "q" then puts "Goodbye!"
			when "t" then tweet(parts[1..-1].join(" "))
			when "dm" then dm(parts[1], parts[2..-1].join(" "))
			when "spam" then spam_my_followers(parts[1..-1].join(" "))
			when "elt" then everyones_last_tweet
			else
				puts "Sorry, I don't know how to #{command}"
			end
		end
	end

	def dm(target, message)
		screen_names = @client.followers.collect { |follower| @client.user(follower).screen_name }
		if screen_names.include?(target)
			puts "Trying to send #{target} the direct message:"
			puts message
			message = "d @#{target} #{message}"
			tweet (message)
		else
			puts "You can't DM #{target} because they're not following you!"
		end
	end

	def followers_list
		screen_names = []
		@client.followers.each { |follower| screen_names << @client.user(follower).screen_name }
		screen_names
	end

	def spam_my_followers(message)
		followers = followers_list
		followers.each { |follower| dm(follower, message) }
	end

	def everyones_last_tweet
		friends_list = @client.friends.take(10)
		friend_objects = friends_list.collect { |friend| @client.user(friend) }
		friends_sorted = friend_objects.sort_by { |friend| friend.screen_name.downcase }
		friends_sorted.each do |friend|
			last_message = friend.status.text
			screen_name = friend.screen_name
			timestamp = friend.status.created_at
			printf "#{screen_name} on #{timestamp.strftime("%A, %b %d")}: "
			puts last_message
			puts ""
		end
	end
end

blogger = MicroBlogger.new
blogger.run