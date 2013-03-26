# Stomp Droid

...is a fork of Stomping Ground (https://github.com/frankmt/stomping_ground), rewritten from EventMachine to Celluloid::IO, so JRuby-compatible.

Original (but adapted) README following.

Fake stomp server to be used when testing stomp consumers and producers. It currently covers just basic functionality, but the roadmap is exciting!

[![Code Climate](https://codeclimate.com/badge.png)](https://codeclimate.com/github/frankmt/stomp_droid)

## Getting Started

Here is an example of how stomping ground could be used with rspec and onstomp

    require 'stomp_droid'
    require 'onstomp'

    describe 'consumer' do

      it "should do something amazing when a message is received" do
        server_thread = Thread.new do
          StompDroid::Server.new('127.0.0.1','9000').start(:message => "message that will be sent")
        end

        client = OnStomp::Client("stomp://127.0.0.1:9000")
        client.connect
        client.subscribe("/queue") do |message|
          #do something amazing with the message
        end 

        client.should have_done_something_amazing
        client.disconnect

        server_thread.terminate
        server_thread.join
      end

    end

    describe 'publisher' do

      it "should publish message to queue when publish is called" do
        server_thread = Thread.new do
          StompDroid::Server.new('127.0.0.1','9000').start(:sent_message_dir => '/tmp/)
        end

        client = OnStomp::Client("stomp://127.0.0.1:9000")
        client.connect
        client.publish("/queue", "my message")

        60.times do
          break if (files = Dir["/tmp/*.msg"].to_a).length > 1
          sleep 0.1
        end

        got_messages = Dir["/tmp/*.msg"]
        got_messages.should have_at_least(1).message

        file_contents = File.read(got_messages.first)
        file_contents.should include("my_message")

        server_thread.terminate
        server_thread.join
      end

    end

## Current Support 

Stomping Ground currently supports the current frames:

* CONNECT
* DISCONNECT
* SUBSCRIBE
* SEND


