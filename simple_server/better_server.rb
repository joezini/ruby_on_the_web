require 'socket'

server = TCPServer.open(80)
loop {
	client = server.accept
	request_full = client.gets
	request_header = request_full.match(/(.+) (.+) (.+)/)
	puts request_header
	path = request_header[2]
	version = request_header[3]
	
	case request_header[1] 
	when 'GET'
		if File.exists?(path[1..-1])
			code = "200"
			message = "OK"
			body = File.readlines(path[1..-1]).join
		else
			code = "404"
			message = "Not found"
			body = ""
		end
	when 'POST'
		puts request_full
	else
		code = "400"
		message = "Incorrect request"
		body = ""
	end

	status = "HTTP/1.1 #{code} #{message}"
	headers = "Date: #{Time.now}\nContent-Type: text/html\nContent-length: #{body.length}"
	response = "#{status}\r\n#{headers}\r\n\r\n#{body}"

	client.print(response)

	client.close
}