module StompDroid
  class Server
    include Celluloid::IO

    attr_accessor :message_body
    attr_accessor :queue_name
    attr_accessor :sent_message_dir

    def initialize(host, port, options = {})
      @host = host
      @port = port

      @message_body     = options[:message]
      @queue_name       = options[:queue_name]
      @sent_message_dir = options[:sent_message_dir]

      @server = TCPServer.new(@host, @port)

      async.run
    end

    def self.start(*opts)
      supervise(*opts)
    end

    def run
      loop { async.handle_connection @server.accept }
    end

    def handle_connection(socket)
      Connection.new(self, socket).handle
    end

    def finalize
      @server.close if @server
    end

  end
end
