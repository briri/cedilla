require_relative '../test_helper'

# This test object should only evaluate the generic functionality of the service object
# individual tests should be written for each implmentation!!!
class TestService < Test::Unit::TestCase

  def setup
    @factory = Cedilla::ServiceFactory.new
  end

# --------------------------------------------------------------------------------------------------------  
  def test_initialization
    @factory.names.each do |name|
      svc = @factory.create(name)
      
      assert svc.is_a?(Cedilla::Service), "For some reason #{name} is not an instance of Cedilla::Service!"
      assert svc.errors.empty?, "The service was created but has errors: #{svc.errors.inspect}"
    end
  end

# --------------------------------------------------------------------------------------------------------    
  def test_submit
    
  end
  
  def test_process
    
  end
  
  def test_build_target
    
  end
  
end

# --------------------------------------------------------------------------------------------------------------------
# Mock service for testing
# --------------------------------------------------------------------------------------------------------------------
class AmazonService < Cedilla::Service
    def submit(citation)
      
      citation.author_full_name = 'Doe, John'
      citation.abstract = 'This is an example abstract returned from our test service to augment the citation.'
      
      citation.resources << Cedilla::Resource.new({:source => 'Some website', :location => nil, :target => 'http://www.ucop.edu', :format => 'electronic'})
      
      citation
    end
end
