module FakeStomp
  
  class Server

    def initialize(host, port)
      @host = host
      @port = port
    end

    def start
      server = TCPServer.new(@host, @port)
      client = server.accept
      frame = client.readline
      puts frame
      client.write 'CONNECTED'
      client.write 'version:1.1'
    end

  end

end
