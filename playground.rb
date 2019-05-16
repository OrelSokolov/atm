require_relative 'lib/atm'

b = ATM.new(true)
# b.put_infinite_money!
b.add_money!({ 50 => 20, 25 => 20, 5 => 8, 2 => 0, 1 => 1}.to_json)
puts b.reload.balance
# puts b.balance_hash
# puts b.fast_search(223)
# puts
#
# variants =  b.br(223)
# puts variants
# puts variants.length
# puts variants.uniq.length

b.auto_get_money!(110)
puts b.balance
