require 'rack/test'
#require 'eventmachine'

#require 'httpclient'

require_relative '../test_helper'

class TestCedillaController < Test::Unit::TestCase
  include Rack::Test::Methods

  def app
    # Need to start EventMachine in a new thread for testing
    #Thread.new { EventMachine.run }
    EventMachine.run
    
    Cedilla::Aggregator.new    
  end
  
  def test_stream
    puts "\nstarting at: #{Time.now}"

    get('/stream?genre=book&content_type=full_text&title=Some%20Book'){
      puts "in get"
    }
    
    while !last_response.body.include?('request_id": "1')
      puts "body at: #{Time.now} : #{last_response.body}"
      sleep 5
    end

    assert 1 == 1
  end
  
end

# --------------------------------------------------------------------------------------------------------------------
# Mock services for testing core component logic
# --------------------------------------------------------------------------------------------------------------------
class AmazonService < Cedilla::Service
    def submit(citation)
      sleep(8)  # sleep to ensure that the broker is handling async calls and that it shuts down when its supposed to!
      
      citation.author_full_name = 'Doe, John'
      citation.abstract = 'This is an example abstract returned from our test service to augment the citation.'
      
      citation.resources << Cedilla::Resource.new({:source => 'Some website', :location => nil, :target => 'http://www.ucop.edu', :format => 'electronic'})
      
      citation
    end
end

class GoogleBooksService < Cedilla::Service
    def submit(citation)
      citation.subject = 'general'
      
      citation.resources << Cedilla::Resource.new({:source => 'The all knowing Google', :target => 'http://www.ucop.edu/google/1', :format => 'electronic'})
      citation.resources << Cedilla::Resource.new({:source => 'The all knowing Google', :target => 'http://www.ucop.edu/google/2', :format => 'electronic'})
      
      citation
    end
end
