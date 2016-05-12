require 'net/http'
require 'json'

def valid_choice?(choice)
	choice.downcase == "g" || choice.downcase == "p"
end

def get(host, path)
	http = Net::HTTP.new(host, 80)
	http.get(path)
end

def post(host, path, details)
	 #headers = "Content-Type: application/x-www-form-urlencoded\nContent-Length: #{details.length}"
	 http = Net::HTTP.new(host, 80)
	 http.post(path, details)
end

choice = ""
until valid_choice?(choice)
	puts "Would you like to (G)et or (P)ost?"
	choice = gets.chomp
end

response = case choice.downcase
when "g"
	host = 'localhost'
	path = '/index.html'
	get(host, path)
when "p"
	host = 'localhost'
	path = '/thanks.html'
	puts "Please give a name:"
	name = gets.chomp
	puts "Please give an email:"
	email = gets.chomp
	details = {viking: {name: name, email: email}}.to_json
	post(host, path, details)
end

if response.code == "200"
	print response.body
else
	puts "#{response.code} #{response.message}"
end

	 




