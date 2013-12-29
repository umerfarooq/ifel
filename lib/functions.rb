# To change this template, choose Tools | Templates
# and open the template in the editor.

class Functions
  def initialize
    
  end

  # http://snippets.dzone.com/posts/show/898
  def Functions.randomize_weighted_array(source, weights=nil)
    return Functions.randomize_weighted_array(source, source.map {|n| n.send(weights)}) if weights.is_a? Symbol

    weights ||= Array.new(source.length, 1.0)
    total = weights.inject(0.0) {|t,w| t+w}
    point = rand * total

    source.zip(weights).each do |n,w|
      return n if w >= point
      point -= w
    end
  end

end
