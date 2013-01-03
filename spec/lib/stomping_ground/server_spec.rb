require 'spec_helper'

describe StompingGround do

  let(:stomp_host)  { '127.0.0.1' }
  let(:stomp_port)  { 8765 }
  let(:queue_name)  { '/queue/foo' }
  let(:message_dir) { "/tmp/stomping-ground-sent-msgs" }
  let(:start_ops)  do
    { :queue_name => queue_name, :sent_message_dir => message_dir }
  end

  let(:client) do
    OnStomp::Client.new("stomp://#{stomp_host}:#{stomp_port}")
  end

  before do
    @server_thread = StompingGround::Server.start(stomp_host, stomp_port, start_ops)
    sleep 0.1
  end

  after do
    @server_thread.terminate
    FileUtils.rm_rf(message_dir)
  end

  describe "connection and subscription" do

    it "should allow client to connect and disconnect" do
      client.connect
      client.connected?.should be_true
      client.disconnect
      client.connected?.should be_false 
    end

    it "should allow client to subscribe" do
      client.connect
      client.subscribe("/queue/foo") do |message|
      end
      client.disconnect
    end

  end

  describe "publishing" do

    let(:json_message) { {"test" => "testing"}.to_json }
    #let(:start_opts) do
      #{
        #:queue_name       => queue_name,
        #:sent_message_dir => message_dir
      #}
    #end

    it "should write message to filesystem whenever its received" do
      client.connect
      client.send(queue_name, json_message)

      60.times do
        break if (files = Dir["#{message_dir}/*.msg"].to_a).length > 1
        sleep 0.1
      end

      got_messages = Dir["#{message_dir}/*.msg"]
      got_messages.should have_at_least(1).message

      file_contents = File.read(got_messages.first)
      file_contents.should include(json_message)
    end

  end

  describe "messages" do

    it "should send message when client subscribes" do
      message_received = false
      client.connect
      client.subscribe("/queue/foo") do |message|
        message_received = true
      end
      sleep 0.1 while message_received == false
      message_received.should be_true
      client.disconnect
    end

    it "should send message defined by client" do
      message_received = false

      expected_msg_body = {:first => 1, :second => 2}.to_json

      server_thread = StompingGround::Server.start('127.0.0.1','3456',
        :message => expected_msg_body
      )

      client = OnStomp::Client.new("stomp://127.0.0.1:3456")
      client.connect
      client.subscribe("/whatever") do |message|
        message_received = true if message.body == expected_msg_body
      end

      sleep 0.1 while message_received == false

      client.disconnect
      server_thread.terminate
    end

    it "should send message if queue is specified and is the correct one" do
      message_received = false

      expected_msg_body = {:first => 1, :second => 2}.to_json
      server_thread = StompingGround::Server.start('127.0.0.1','3456',
        :message => expected_msg_body,
        :queue_name => "/queue/my_queue"
      )

      client = OnStomp::Client.new("stomp://127.0.0.1:3456")
      client.connect
      client.subscribe("/queue/my_queue") do |message|
        message_received = true if message.body == expected_msg_body
      end

      sleep 0.1 while message_received == false

      client.disconnect
      server_thread.terminate
    end

    it "should not send message if client is not subscribed to the correct queue" do
      message_received = false

      expected_msg_body = {:first => 1, :second => 2}.to_json
      server_thread = StompingGround::Server.start('127.0.0.1','3456',
        :message => expected_msg_body,
        :queue_name => "/queue/my_queue"
      )

      client = OnStomp::Client.new("stomp://127.0.0.1:3456")
      client.connect
      client.subscribe("/queue/wrong_queue") do |message|
        message_received = true if message.body == expected_msg_body
      end

      sleep 1

      message_received.should be_false

      client.disconnect
      server_thread.terminate
    end

  end
end
