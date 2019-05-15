class Bankomat
  ALLOWED_KEYS = [50, 25, 10, 5, 2, 1]

  def initialize
    @money = default_hash
  end

  def put_inside(money_hash)
    money_hash.each do |k, v|
      @money[k] += v
    end
  end

  # Just for your checks
  def put_infinite_money
    {50 => 10000,
     25 => 10000,
     10 => 10000,
     5 => 10000,
     2 => 10000,
     1 => 10000 }.each do |k, v|
      @money[k] += v
    end
  end

  def get_money(money_hash)

  end

  # Get money with first variant
  def auto_get_money(money_sum)
  end

  def generate_variants_for(money_sum, allowed_keys)
    result = default_hash
    left = money_sum
    allowed_keys.each do |key|
      result[key] = left/key.to_i
      left = left % key
      break if (left % key).zero?
    end
    result
  end

  def hash_correct?(hash)
    hash.keys.all? { |key| ALLOWED_KEYS.include?(key) }
  end

  # Check if we have enough money for combination
  def enough_money_for?(hash)
    hash.keys.all?{|key| @money[key] >= hash[key]}
  end

  def balance_hash
    @money
  end

  def balance
    sum = 0
    @money.each do |k, v|
      sum += v
    end
    sum
  end

  def default_hash
    hash = {}
    ALLOWED_KEYS.each do |key|
      hash[key] = 0
    end
    hash
  end

  # Calc limits for k1*x1 element
  # We simply devide Y to k1 and we will get maximum amount we need to build
  # sum. More will cause overflow.
  # Also we see if there is some ACTUAL limitations in our ATM - not enough key values loaded
  def max_limits(sum)
    hash = default_hash
    hash.each do |k, v|
      hash[k] = (sum/k < @money[k]) ? sum/k : @money[k]
    end
    hash
  end

  # Also add min limit to avoid wasting time
  # Min limit shows if we NEED some amount of key
  # because if value is not enough we can not build sum at all.
  # All variants with value less then current does not make sense
  # because sum of each of them less then we need
  def min_limits(sum)
    hash = max_limits(sum)
    result_hash = {}
    hash.each do |k, v|
      index = v
      while index > 0
        break if sum_kv(hash, k, index-1) < sum
        index -= 1
      end
      result_hash[k] = index
    end
    result_hash
  end

  # Sum hash with, overriding key with given value
  def sum_kv(hash, key, value)
    result = 0
    hash.each do |k, v|
      if k == key
        result += k*value
      else
        result += k*v
      end
    end
    result
  end

  # Sum hash to see how much we have for now
  def sum(hash)
    result = 0
    hash.each do |k, v|
      result += k*v
    end
    result
  end

  # Shows how much variants we need to check
  def bruteforce_variants_count(sum)
    result = 1
    mins = min_limits(sum)
    maxs = max_limits(sum)

    default_hash.each do |k, v|
      result *= (maxs[k] - mins[k] + 1)
    end
    result
  end

  def bruteforce_variants(sum)
    results = []
    mins = min_limits(sum)
    maxs = max_limits(sum)

    default_hash.keys do |k|


    end

    results
  end

  def br(sum)
    ranges_to_brute = {}
    mins = min_limits(sum)
    maxs = max_limits(sum)

    default_hash.each do |k, v|
      ranges_to_brute[k] = (mins[k]..maxs[k]).to_a unless @money[k].zero?
    end

    puts ranges_to_brute

    sorted_keys = ranges_to_brute.keys.sort{|x, y| ranges_to_brute[x].length <=> ranges_to_brute[y].length}.reverse
    puts sorted_keys.inspect

    results = []
    (0...bruteforce_variants_count(sum)).each do |i|
      previous_devidor = 1
      h = default_hash

      sorted_keys.each do |k|
        h[k] = ranges_to_brute[k][i/previous_devidor%ranges_to_brute[k].length]
        previous_devidor *= ranges_to_brute[k].length
      end
      results << h if sum(h) == sum
    end
    results
  end
end


b = Bankomat.new
# b.put_infinite_money
b.put_inside({ 50 => 20, 25 => 20, 5 => 20, 2 => 20, 1 => 1})
puts b.balance_hash
# puts b.generate_variants_for(223, Bankomat::ALLOWED_KEYS)
# puts b.max_limits 225
# puts b.min_limits 225
# puts b.bruteforce_variants_count 225

variants =  b.br(225)
puts variants
puts variants.length
puts variants.uniq.length
