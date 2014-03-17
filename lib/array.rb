class Array
  def weighted_sample(weights=nil)
    weights ||= Array.new(length, 1.0)
    total = weights.sum
    trigger = Kernel::rand * total
    x = 0
    result = nil
    weights.each_with_index do |weight, index|
      x += weight
      if x > trigger
        result = self[index]
        break
      end
    end
    result || last
  end
end
