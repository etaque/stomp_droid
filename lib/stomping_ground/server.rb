module StompingGround

  module Stomp

    attr_writer :message_body

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
        message = @message_body || "hello"
        send_data "MESSAGE\n"
        send_data "subscription:#{frame_info[:id]}\n"
        send_data "message-id:007\n"
        send_data "destination:#{frame_info[:destination]}\n"
        send_data "content-type:text/plain\n"
        send_data "content-length:#{message.length}\n"
        send_data "\n"
        send_data "#{message}\0"
      when "DISCONNECT"
        send_data "RECEIPT\n"
        send_data "receipt-id:99\n"
        send_data "\0"
        close_connection
      when "SEND"
        File.open("stomping_ground_message.txt", "w") do |file|
          file.write(frame)
        end
      end
    end

    def unbind
    end

    private

    def parse(frame)
      frame_info = {}
      data_array = frame.split("\n").reverse
      frame_info[:command] = data_array.pop
      data_array.each do |info|
        if info.include?(':')
          frame_info[info.split(':')[0].to_sym] = info.split(':')[1]
        end
      end
      frame_info
    end

  end

  class Server

    def initialize(host, port)
      @host = host
      @port = port
    end

    def start(options={})
      EventMachine.run {
        EventMachine.start_server @host, @port, StompingGround::Stomp do |server|
          server.message_body = options[:message]
        end
      }
    end

  end

end


