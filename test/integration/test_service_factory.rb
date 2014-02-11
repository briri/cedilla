require_relative '../test_helper'

class TestServiceFactory < Test::Unit::TestCase

  def setup
    @factory = Cedilla::ServiceFactory.new
  end

# --------------------------------------------------------------------------------------------------------  
  def test_initialization
    # Make sure the service list was loaded
    assert !@factory.names.empty?, "Should have loaded some service configurations into the factory!"
  end
  
# --------------------------------------------------------------------------------------------------------  
  def test_create
    # Make sure each of the services can be instantiated
    # This should work even if there is no specific implementation of the service. It should default 
    # to the generic Cedilla::Service class
    @factory.names.each do |svc|
      assert @factory.create(svc).is_a?(Cedilla::Service), "For some reason the factory could not instantiate #{svc}! You may want to run specific tests for that service's implementation."
    end
    
  end  
  
end