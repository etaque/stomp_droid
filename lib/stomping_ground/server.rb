require 'socket'
require 'eventmachine'

module StompingGround

  module Stomp

    def post_init
    end

    def receive_data frame
      frame_info = parse(frame)
      case frame_info[:command]
        when "CONNECT"
        send_data "CONNECTED\n"
        send_data "version:1.1\n"
        send_data "\n"
        send_data "\0"
       when "SUBSCRIBE"
        send_data "MESSAGE\n"
        send_data "subscription:#{frame_info[:id]}\n"
        send_data "message-id:007\n"
        send_data "destination:#{frame_info[:destination]}\n"
        send_data "content-type:text/plain\n"
        send_data "content-length:5\n"
        send_data "\n"
        send_data "hello\0"
        when "DISCONNECT"
        send_data "RECEIPT\n"
        send_data "receipt-id:99\n"
        send_data "\0"
        close_connection
      end
    end

    def unbind
    end

    private

    def parse(data)
      data_array = data.split("\n").reverse
      command_info = {}
      command_info[:command] = data_array.pop
      data_array.each do |info|
        if info.include?(':')
          command_info[info.split(':')[0].to_sym] = info.split(':')[1]
        end
      end
      command_info
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


