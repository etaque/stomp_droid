require 'spec_helper'

describe "stomp client behaviour" do

  it "should send something" do
    Thread.new do 
      server = TCPServer.new('127.0.0.1', 2000)
      client = server.accept
      puts client.class
      while line = client.readline 
        puts line.inspect
        break if line == "\n"
      end
      client.close
    end

    client = OnStomp::Client.new("stomp://127.0.0.1:2000")
    client.connect
    client.disconnect
  end
end
