

class SfxService < Cedilla::Service
  
  def process(original_citation, response = nil)
    return Cedilla::Citation.new({:issue => 'Spring 2013', :author_full_name => 'Doe, John'})
  end

  def build_target
    return nil
  end
  
end