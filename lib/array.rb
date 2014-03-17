class Array
  def weighted_sample(weights=nil)
    weights ||= Array.new(length, 1.0)

    total = weights.sum

    # The total sum of weights is multiplied by a random number
    trigger = Kernel::rand * total

    sum = 0
    result = nil

    # The sum is checked agains the trigger. The higher the sum, the higher
    # the probability of triggering a result.
    weights.each_with_index do |weight, index|
      sum += weight

      if sum > trigger
        result = self[index]
        break
      end
    end
    # Returns self.last from current array if result is nil
    result || last
  end
end
