require 'socket'
require 'eventmachine'

module StompingGround

  module Stomp

    def post_init
    end

    def receive_data data
      command = data.split("\n")[0]
      if command =~ /^CONNECT/
        send_data "CONNECTED\n"
        send_data "version:1.1\n"
        send_data "\n"
        send_data "\0"
      elsif command =~ /DISCONNECT/ 
        send_data "RECEIPT\n"
        send_data "receipt-id:99\n"
        send_data "\0"
        close_connection
      end
    end

    def unbind
    end

  end

  class Server

    def initialize(host, port)
      @host = host
      @port = port
    end

    def start
      EventMachine.run {
        EventMachine.start_server @host, @port, StompingGround::Stomp
      }
    end

  end

end


