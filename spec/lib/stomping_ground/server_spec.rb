require 'spec_helper'

describe StompingGround do

  let(:stomp_uri) { 'stomp://127.0.0.1:2000' }

  it "should allow client to connect and disconnect" do
    server_thread = Thread.new do
      StompingGround::Server.new('127.0.0.1','2000').start
    end

    client = OnStomp::Client.new("stomp://127.0.0.1:2000")
    client.connect
    client.connected?.should be_true
    client.disconnect
    client.connected?.should be_false 

    server_thread.join
    server_thread.terminate
  end

  it "should allow client to subscribe" do
    server_thread = Thread.new do
      StompingGround::Server.new('127.0.0.1','2000').start
    end

    client = OnStomp::Client.new("stomp://127.0.0.1:2000")
    client.connect
    client.subscribe("queue", :ack => 'client') do |message|
    end
    client.disconnect

    server_thread.join
    server_thread.terminate
  end

end
