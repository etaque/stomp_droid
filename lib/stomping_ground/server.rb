require 'socket'

module StompingGround
  
  class Server

    def initialize(host, port)
      @host = host
      @port = port
    end

    def start
      @server = TCPServer.new(@host, @port)
      puts "server really started"
      client = @server.accept
      puts "accepted client"
      while frame = client.readline do
        break if frame == "\0"
        puts frame
        if frame =~ /CONNECT/
          client.write "CONNECTED\n"
          client.write "version:1.1\n"
          client.write "\n"
          client.write "\0"
          client.close
        elsif frame =~ /DISCONNECT/
          client.write "RECEIPT\n"
          client.write "receipt-id:99\n"
          client.write "\0"
          client.close
        end
      end
    end

  end

end
