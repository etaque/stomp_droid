require 'spec_helper'

describe StompingGround do

  let(:stomp_host) { '127.0.0.1' }
  let(:stomp_port) { 8000 }

  before :each do
    @server_thread = Thread.new do
      StompingGround::Server.new(stomp_host, stomp_port).start(
        :queue_name => "/queue/foo"
      )
    end
    @client = OnStomp::Client.new("stomp://#{stomp_host}:#{stomp_port}")
  end

  after :each do
    @server_thread.terminate
    @server_thread.join
  end

  describe "connection and subscription" do

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
    let(:json_message) { {"test" => "testing"}.to_json }
    let(:queue_name) { "/queue/name" }

    before :each do
      File.delete(message_filename) rescue nil
    end

    it "should write message to filesystem whenever its received" do
      @client.connect
      @client.send(queue_name, json_message)

      file = nil
      while file.nil?
        file = File.read(message_filename) rescue nil
        sleep 0.1
      end

      file.should include(json_message)
      file.should include(queue_name)
    end

    it "should allow filename to be defined on start" do
      filename = "test_filename.txt"
      File.delete(filename) rescue nil

      server_thread = Thread.new do
        StompingGround::Server.new('127.0.0.1','7000').start(
          :published_message_filename => filename
        )
      end

      client = OnStomp::Client.new("stomp://127.0.0.1:7000")
      client.connect
      client.send("/queue/name", json_message)

      file = nil
      while file.nil?
        file = File.read(filename) rescue nil
        sleep 0.1
      end

      file.should include(json_message)
      
      client.disconnect
      server_thread.terminate
      server_thread.join
    end

  end

  describe "messages" do

    it "should send message when client subscribes" do
      message_received = false
      @client.connect
      @client.subscribe("/queue/foo") do |message|
        message_received = true
      end
      sleep 0.1 while message_received == false
      message_received.should be_true
      @client.disconnect
    end

    it "should send message defined by client" do
      message_received = false

      expected_msg_body = {:first => 1, :second => 2}.to_json
      server_thread = Thread.new do
        StompingGround::Server.new('127.0.0.1','3000').start(
          :message => expected_msg_body
        )
      end

      client = OnStomp::Client.new("stomp://127.0.0.1:3000")
      client.connect
      client.subscribe("/whatever") do |message|
        message_received = true if message.body == expected_msg_body
      end

      sleep 0.1 while message_received == false
      
      client.disconnect
      server_thread.terminate
      server_thread.join
    end

    it "should send message if queue is specified and is the correct one" do
      message_received = false

      expected_msg_body = {:first => 1, :second => 2}.to_json
      server_thread = Thread.new do
        StompingGround::Server.new('127.0.0.1','3000').start(
          :message => expected_msg_body,
          :queue_name => "/queue/my_queue"
        )
      end

      client = OnStomp::Client.new("stomp://127.0.0.1:3000")
      client.connect
      client.subscribe("/queue/my_queue") do |message|
        message_received = true if message.body == expected_msg_body
      end

      sleep 0.1 while message_received == false
      
      client.disconnect
      server_thread.terminate
      server_thread.join
    end

    it "should not send message if client is not subscribed to the correct queue" do
      message_received = false

      expected_msg_body = {:first => 1, :second => 2}.to_json
      server_thread = Thread.new do
        StompingGround::Server.new('127.0.0.1','3000').start(
          :message => expected_msg_body,
          :queue_name => "/queue/my_queue"
        )
      end

      client = OnStomp::Client.new("stomp://127.0.0.1:3000")
      client.connect
      client.subscribe("/queue/wrong_queue") do |message|
        message_received = true if message.body == expected_msg_body
      end

      sleep 1

      message_received.should be_false
      
      client.disconnect
      server_thread.terminate
      server_thread.join
    end

  end
end
