require 'spec_helper'

describe "Stomp Server" do

  let(:stomp_uri) { 'localhost:61613' }

  it "should allow client to connect" do
    client = OnStomp::Client.new(stomp_uri)
    client.connect
  end
end
