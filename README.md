#Stomping Ground

Fake stomp server to be used when testing stomp consumers. It currently covers just basic functionality, but the roadmap is exciting!

## Getting Started

Here is an example of how stomping ground could be used with rspec an onstomp

    require 'stomping_ground'
    require 'onstomp'

    describe 'consumer' do

      it "should do something amazing when a message is received" do
        server_thread = Thread.new do
          StompingGround::Server.new('127.0.0.1','9000').start
        end

        client = MyConsumer.new("stomp://127.0.0.1:9000")
        client.should have_done_something_amazing
        client.disconnect

        server_thread.terminate
      end

    end

## Roadmap

Stomping Ground currently supports the current frames:

* CONNECT
* DISCONNECT
* SUBSCRIBE


