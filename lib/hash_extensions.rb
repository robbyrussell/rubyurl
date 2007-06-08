#
# Based on http://pastie.caboo.se/10707
#

class Hash
  # Returns the hash with entries removed
  #   { :a => 1, :b => 2, :c => 3}.except(:a) -> { :b => 2, :c => 3 }
  #   { :a => 1, :b => 2, :c => 3}.except(:a, :c) -> { :b => 2 }
  def except(*keys)
    self.reject { |k,v| keys.include? k.to_sym }
  end unless instance_methods.include? 'except'
  
  # Returns a new hash with only the entries specified
  #   { :a => 1, :b => 2, :c => 3}.only(:a) -> { :a => 1 }
  #   { :a => 1, :b => 2, :c => 3}.only(:a, :b) -> { :a => 1, :b => 2 }
  def only(*keys)
    self.dup.reject { |k,v| !keys.include? k.to_sym }
  end unless instance_methods.include? 'only'
end