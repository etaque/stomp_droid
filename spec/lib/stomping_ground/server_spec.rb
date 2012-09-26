require 'spec_helper'

describe StompingGround do

  let(:stomp_uri) { 'stomp://127.0.0.1:2000' }

  before :each do
    @server_thread = Thread.new do
      StompingGround::Server.new('127.0.0.1','2000').start
    end
  end

  after :each do
    @server_thread.terminate
  end

  it "should allow client to connect and disconnect" do
    client = OnStomp::Client.new("stomp://127.0.0.1:2000")
    client.connect
    client.connected?.should be_true
    client.disconnect
    client.connected?.should be_false 
  end

  it "should allow client to subscribe" do
    client = OnStomp::Client.new("stomp://127.0.0.1:2000")
    client.connect
    client.subscribe("queue", :ack => 'client') do |message|
    end
    client.disconnect
  end

  it "should send specified message when client subscribes" do
    pending
  end

end
