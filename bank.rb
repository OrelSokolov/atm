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
    show_varitants_for(money_sum)

  end

  def show_varitants_for(money_sum)
    arr = ALLOWED_KEYS.dup
    variants = []

    (0...ALLOWED_KEYS.length).to_a.each do |x|
      variants.push(generate_variants_for(money_sum, arr.slice(x, ALLOWED_KEYS.length)))
    end

    variants.select{ |var| enough_money_for?(var) }
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
end


b = Bankomat.new
b.put_infinite_money
puts b.generate_variants_for(200, [50, 25])