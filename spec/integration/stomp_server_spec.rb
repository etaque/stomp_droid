require 'spec_helper'

describe "Stomp Server" do

  let(:stomp_uri) { 'stomp://127.0.0.1:2000' }

  it "should allow client to connect" do
    Thread.new do
      FakeStomp::Server.new('127.0.0.1','2000').start
    end

    client = OnStomp::Client.new("stomp://127.0.0.1:2000")
    client.connect
    client.connected?.should be_true
  end

end
