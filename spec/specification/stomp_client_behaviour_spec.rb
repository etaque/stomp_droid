require 'spec_helper'

describe "stomp client behaviour" do

  it "should send something" do
    Thread.new do 
      server = TCPServer.new('127.0.0.1', 2000)
      puts "Server started"
      client = server.accept
      puts "accepted request"
      client.puts "Hello !"
      client.puts "Time is #{Time.now}"
      client.close
    end
    puts "trying to connect stomp"
    client = OnStomp::Client.new("stomp://127.0.0.1:2000")
    client.connect
    puts "connected to stomp"
    client.disconnect
  end
end
