module StompingGround
  
  class Server

    def initialize(host, port)
      @host = host
      @port = port
    end

    def start
      server = TCPServer.new(@host, @port)
      client = server.accept
      frame = client.readline
      client.write "CONNECTED\n"
      client.write "version:1.1\n"
      client.write "\n"
      client.write "\0"
    end

  end

end
