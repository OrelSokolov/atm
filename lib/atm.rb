# frozen_string_literal: true

require 'redis'
require 'json'

# This class represents ATM that can calculate combinations to give you money
class ATM
  class NotEnoughMoneyError < RuntimeError; end

  ALLOWED_KEYS = [50, 25, 10, 5, 2, 1].freeze

  def initialize(redis = nil)
    @use_redis = redis
    reload
  end

  def reload
    @money = if @use_redis
               load!
             else
               default_hash
             end
    self
  end

  # Make ATM empty
  def empty!
    @money = default_hash
    save!
  end

  # Add money by JSON
  def add_money!(json)
    put_inside!(money_from_json(json))
  end

  # Put money HASH inside ATM
  def put_inside!(money_hash)
    money_hash.each do |k, v|
      @money[k] += v
    end
    save!
  end

  # Put a lot of money to ATM
  def put_infinite_money!
    { 50 => 10_000,
      25 => 10_000,
      10 => 10_000,
      5 => 10_000,
      2 => 10_000,
      1 => 10_000 }.each do |k, v|
      @money[k] += v
    end
    save!
  end

  # Get money buy integer value, auto select random case
  def auto_get_money!(money_sum)
    raise NotEnoughMoneyError, 'Insuficient balance' if money_sum > balance

    combination = fast_search(money_sum) || br(money_sum).sample
    raise NotEnoughMoneyError, 'Could not find combination for this sum with current money hash' unless combination

    get_money!(combination)
    combination
  end

  # Fast search if we have unlimited money resources
  # Not usable for edge cases
  def fast_search(money_sum)
    result = default_hash
    left = money_sum
    allowed_keys = ALLOWED_KEYS.select { |k| @money[k] > 0 }
    allowed_keys.each do |key|
      result[key] = left / key.to_i
      left = left % key
      break if (left % key).zero?
    end
    enough_money_for?(result) ? result : nil
  end

  # Returns balance as hash
  def balance_hash
    @money
  end

  # Returns balance as integer value
  def balance
    sum = 0
    @money.each do |k, v|
      sum += k * v
    end
    sum
  end

  # Shows how much variants we need to check
  def bruteforce_variants_count(sum)
    result = 1
    mins = min_limits(sum)
    maxs = max_limits(sum)

    default_hash.each do |k, _v|
      result *= (maxs[k] - mins[k] + 1)
    end
    result
  end

  # Bruteforce with clever limitations
  # Not usable if we have a lot of money inside
  def br(sum)
    ranges_to_brute = {}
    mins = min_limits(sum)
    maxs = max_limits(sum)

    default_hash.each do |k, _v|
      ranges_to_brute[k] = (mins[k]..maxs[k]).to_a unless @money[k].zero?
    end

    # Sort keys by desc to build matrix then
    sorted_keys = ranges_to_brute.keys.sort { |x, y| ranges_to_brute[x].length <=> ranges_to_brute[y].length }.reverse

    results = []
    (0...bruteforce_variants_count(sum)).each do |i|
      previous_devidor = 1
      h = default_hash

      sorted_keys.each do |k|
        h[k] = ranges_to_brute[k][i / previous_devidor % ranges_to_brute[k].length]
        previous_devidor *= ranges_to_brute[k].length
      end
      results << h if sum(h) == sum
    end
    results
  end

  private

  def redis
    @redis ||= Redis.new
  end

  # Load money from redis
  def load!
    money = redis.get('money')
    money && @use_redis ? money_from_json(money) : default_hash
  end

  # Save money to redis database
  def save!
    redis.set('money', @money.to_json) if @use_redis
  end

  # Get money by hash, change balance
  def get_money!(money_hash)
    raise NotEnoughMoneyError, 'Not enough money for found combination' unless enough_money_for?(money_hash)

    money_hash.keys.each { |key| @money[key] -= money_hash[key] }
    save!
  end

  # Sum hash with, overriding key with given value
  def sum_kv(hash, key, value)
    result = 0
    hash.each do |k, v|
      result += if k == key
                  k * value
                else
                  k * v
                end
    end
    result
  end

  # Sum hash to see how much we have for now
  def sum(hash)
    result = 0
    hash.each do |k, v|
      result += k * v
    end
    result
  end

  # Check if we have no extra keys in given hash
  def hash_correct?(hash)
    hash.keys.all? { |key| ALLOWED_KEYS.include?(key) }
  end

  # Check if we have enough money for combination
  def enough_money_for?(hash)
    hash.keys.all? { |key| @money[key] >= hash[key] }
  end

  # Returns default money hash initialized with zero values
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
    hash.each do |k, _v|
      hash[k] = sum / k < @money[k] ? sum / k : @money[k]
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
        break if sum_kv(hash, k, index - 1) < sum

        index -= 1
      end
      result_hash[k] = index
    end
    result_hash
  end

  def money_from_json(json)
    hash1 = JSON.parse(json)
    hash2 = {}
    hash1.each do |k, v|
      hash2[k.to_i] = v.to_i
    end
    hash2
  end
end
