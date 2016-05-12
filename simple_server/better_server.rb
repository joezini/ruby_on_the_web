require 'socket'
require 'json'

server = TCPServer.open(80)
loop {
	client = server.accept
	request_full = ""
	body_length = 0
	reading_body = false
	read_all = false
	body = ""
	until read_all 
		line = client.gets
		request_full << line
		if line[0..14] == 'Content-Length:'
			body_length = line.match(/Content-Length: (.+)/)[1].to_i
		end
		if line.strip.length == 0
			reading_body = true
		end
		if reading_body
			body_length.times do
				body << client.getc
			end
			read_all = true
		end
		if reading_body && body_length == 0
			read_all = true
		end
	end
	puts "Done reading lines"
	request_header = request_full.match(/(.+) (.+) (.+)/)
	path = request_header[2]
	version = request_header[3]
	
	case request_header[1] 
	when 'GET'
		if File.exists?(path[1..-1])
			code = "200"
			message = "OK"
			reply_body = File.readlines(path[1..-1]).join
		else
			code = "404"
			message = "Not found"
			reply_body = ""
		end
	when 'POST'
		code = "200"
		message = "OK"
		params = JSON.parse(body)["viking"]
		html_insert = ""
		params.each do |k, v|
			html_insert << "<li>#{k}: #{v}</li>"
		end
		thanks = File.readlines('thanks.html').join
		reply_body = thanks.sub('<%= yield %>', html_insert)
	else
		code = "400"
		message = "Incorrect request"
		reply_body = ""
	end

	status = "HTTP/1.1 #{code} #{message}"
	headers = "Date: #{Time.now}\nContent-Type: text/html\nContent-length: #{reply_body.length}"
	response = "#{status}\r\n#{headers}\r\n\r\n#{reply_body}"

	client.print(response)

	client.close
}