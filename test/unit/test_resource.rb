require_relative '../test_helper'

class TestResource < Test::Unit::TestCase

  def setup
    
  end

# --------------------------------------------------------------------------------------------------------  
  def test_initialization
    a = Cedilla::Citation.new
    resource = Cedilla::Resource.new(a)
    
    assert_equal a, resource.citation, "The resource's citation should match the original citation!"
  end
  
end