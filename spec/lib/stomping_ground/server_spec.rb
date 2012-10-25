require 'spec_helper'

describe StompingGround do

  let(:stomp_uri) { 'stomp://127.0.0.1:2000' }

  describe "connection and subscription" do

    before :each do
      @server_thread = Thread.new do
        StompingGround::Server.new('127.0.0.1','2000').start
      end
      @client = OnStomp::Client.new("stomp://127.0.0.1:2000")
    end

    after :each do
      @server_thread.terminate
      @server_thread.join
    end

    it "should allow client to connect and disconnect" do
      @client.connect
      @client.connected?.should be_true
      @client.disconnect
      @client.connected?.should be_false 
    end

    it "should allow client to subscribe" do
      @client.connect
      @client.subscribe("/queue/foo") do |message|
      end
      @client.disconnect
    end

  end

  describe "publishing" do

    let(:message_filename) { "stomping_ground_message.txt" }

    before :each do
      File.delete(message_filename)
    end

    it "should write message to filesystem whenever its received" do
      @server_thread = Thread.new do
        StompingGround::Server.new('127.0.0.1','2000').start
      end

      @client = OnStomp::Client.new("stomp://127.0.0.1:2000")
      @client.connect

      json_message = {"test" => "testing"}.to_json
      @client.send("/queue/name", json_message)

      file = nil
      while file.nil?
        file = File.read(message_filename) rescue nil
        sleep 0.1
      end

      file.should include(json_message)

      @server_thread.terminate
      @server_thread.join
    end

  end

  describe "messages" do

    it "should send message when client subscribes" do
      @server_thread = Thread.new do
        StompingGround::Server.new('127.0.0.1','2000').start
      end
      @client = OnStomp::Client.new("stomp://127.0.0.1:2000")

      message_received = false
      @client.connect
      @client.subscribe("/queue/foo") do |message|
        message_received = true
      end
      sleep 0.1 while message_received == false
      message_received.should be_true
      @client.disconnect

      @server_thread.terminate
      @server_thread.join
    end

    it "should send message defined by client" do
      message_received = false

      expected_msg_body = {:first => 1, :second => 2}.to_json
      server_thread = Thread.new do
        StompingGround::Server.new('127.0.0.1','3000').start(:message => expected_msg_body)
      end

      client = OnStomp::Client.new("stomp://127.0.0.1:3000")
      client.connect
      client.subscribe("/queue/foo") do |message|
        message_received = true if message.body == expected_msg_body
      end

      sleep 0.1 while message_received == false
      client.disconnect
      server_thread.terminate
      server_thread.join
    end


    it "should send multiple messages in sequence" do
      pending
      message_count = 0
      @client.connect
      @client.subscribe("/queue/foo") do |message|
        message_count +=1
      end
      sleep 0.1 while message_count < 5
      @client.disconnect
    end

    it "should send messages just after client ack if specified" do
      pending
      message_count = 0
      @client.connect
      @client.subscribe("/queue/foo", :ack => 'client') do |message|
        message_count +=1
        client.ack if message_count <= 5
      end
      sleep 0.1 while message_count <= 5
      message_count.should == 5
      @client.disconnect
    end

    it "should send number of of messages defined by client"

  end

end
