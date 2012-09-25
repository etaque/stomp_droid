require 'socket'

module StompingGround
  
  class Server

    def initialize(host, port)
      @host = host
      @port = port
    end

    def start
      @server = TCPServer.open(@host, @port)
      client = @server.accept
      begin
        loop do
          start_frame = client.readline
          while frame = client.readline do
            break if frame == "\n"
          end

          if start_frame =~ /^CONNECT/
            client.write "CONNECTED\n"
            client.write "version:1.1\n"
            client.write "\n"
            client.write "\0"
          elsif start_frame =~ /DISCONNECT/
            client.write "RECEIPT\n"
            client.write "receipt-id:99\n"
            client.write "\0"
          end
        end
      rescue Exception => e
        client.close
      end
    end

  end

end
