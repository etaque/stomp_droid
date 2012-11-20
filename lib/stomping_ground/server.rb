require 'eventmachine'
require 'fileutils'
require 'openssl'

module StompingGround

  module Stomp

    attr_writer :message_body
    attr_writer :queue_name
    attr_writer :sent_message_dir

    def post_init; end
    def unbind;    end

    def receive_data data
      append_data(data)

      each_frame do |frame|
        frame_info = parse(frame)
        case frame_info[:command]
        when "CONNECT"
          send_data "CONNECTED\n"
          send_data "version:1.1\n"
          send_data "heart-beat:0,0\n" if frame_info[:'heart-beat']
          send_data "\n"
          send_data "\0"
        when "SUBSCRIBE"
          if @queue_name.nil? || frame_info[:destination] == @queue_name
            message = @message_body || "hello"
            send_data "MESSAGE\n"
            send_data "subscription:#{frame_info[:id]}\n"
            send_data "message-id:007\n"
            send_data "destination:#{frame_info[:destination]}\n"
            send_data "content-type:text/plain\n"
            send_data "content-length:#{message.length}\n"
            send_data "\n"
            send_data "#{message}\0"
          end
        when "DISCONNECT"
          if frame_info[:'receipt-id']
            send_data "RECEIPT\n"
            send_data "receipt-id:#{frame_info[:'receipt-id']}\n"
            send_data "\0"
          end
          close_connection
        when "SEND"
          filename = sent_message_filename_for(frame)
          if filename
            dirname = File.dirname(filename)
            FileUtils.mkdir_p(dirname) if !File.exists?(dirname)
            File.open(filename, "w") { |file| file.write(frame) }
          end
        end
      end
    end

    private

    def sent_message_filename_for(frame)
      return nil if !@sent_message_dir
      md5 = OpenSSL::Digest::MD5.new(frame)
      "#{@sent_message_dir}/#{md5}.msg"
    end

    def parse(frame)
      frame_info = {}
      data_array = frame.split("\n").reject { |line| line =~ /^\s+$/ }
      frame_info[:command] = data_array.shift
      data_array.each do |info|
        if info.include?(':')
          frame_info[info.split(':')[0].to_sym] = info.split(':')[1]
        end
      end
      frame_info
    end

    def append_data data
      (@data ||= '') << data
    end

    def each_frame(&block)
      while eoframe = @data.index("\0")
        block.call(@data.slice!(0, eoframe + 1))
      end
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
          server.message_body     = options[:message]
          server.queue_name       = options[:queue_name]
          server.sent_message_dir = options[:sent_message_dir]
        end
      }
    end

  end

end


