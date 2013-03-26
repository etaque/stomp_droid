module StompingGround
  class Connection
    attr_accessor :server, :socket, :frame, :frame_info

    def initialize(server, socket)
      @server = server
      @socket = socket
    end

    def handle
      loop do
        break if @socket.closed?

        data = @socket.readpartial 4096

        append_data(data)

        each_frame do |frame|
          @frame = frame
          @frame_info = parse(frame)
          case frame_info[:command]
          when "CONNECT"
            connect_frame
          when "SUBSCRIBE"
            subscribe_frame
          when "DISCONNECT"
            disconnect_frame
          when "SEND"
            send_frame
          end
        end
      end
    rescue EOFError
      @socket.close
    end

    def connect_frame
      write "CONNECTED\n"
      write "version:1.1\n"
      write "heart-beat:0,0\n" if frame_info[:'heart-beat']
      write "\n"
      write "\0"
    end

    def subscribe_frame
      if @server.message_body && (@server.queue_name.nil? || frame_info[:destination] == @server.queue_name)
        write "MESSAGE\n"
        write "subscription:#{frame_info[:id]}\n"
        write "message-id:007\n"
        write "destination:#{frame_info[:destination]}\n"
        write "content-type:text/plain\n"
        write "content-length:#{message.length}\n"
        write "\n"
        write "#{@server.message_body}\0"
      end
    end

    def disconnect_frame
      if frame_info[:'receipt-id']
        write "RECEIPT\n"
        write "receipt-id:#{frame_info[:'receipt-id']}\n"
        write "\0"
      end
      @socket.close
    end

    def send_frame
      filename = sent_message_filename_for(frame)
      if filename
        dirname = File.dirname(filename)
        FileUtils.mkdir_p(dirname) if !File.exists?(dirname)
        File.open(filename, "w") { |file| file.write(frame) }
      end
    end

    def write(data)
      @socket.write data
    end

    private

    def sent_message_filename_for(frame)
      return nil unless @server.sent_message_dir
      md5 = OpenSSL::Digest::MD5.new(frame)
      "#{@server.sent_message_dir}/#{md5}.msg"
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

end

