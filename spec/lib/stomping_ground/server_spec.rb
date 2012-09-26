require 'spec_helper'

describe StompingGround do

  let(:stomp_uri) { 'stomp://127.0.0.1:2000' }

  before :each do
    @server_thread = Thread.new do
      StompingGround::Server.new('127.0.0.1','2000').start
    end
    @client = OnStomp::Client.new("stomp://127.0.0.1:2000")
  end

  after :each do
    @server_thread.terminate
  end

  it "should allow client to connect and disconnect" do
    @client.connect
    @client.connected?.should be_true
    @client.disconnect
    @client.connected?.should be_false 
  end

  it "should allow client to subscribe" do
    @client.connect
    @client.subscribe("/queue/foo", :ack => 'client') do |message|
    end
    @client.disconnect
  end

  it "should send message when client subscribes" do
    message_received = false
    @client.connect
    @client.subscribe("/queue/foo", :ack => 'server') do |message|
      message_received = true
    end
    sleep 0.1 while message_received == false
    message_received.should be_true
    @client.disconnect
  end

end
