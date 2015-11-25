require 'json'
require_relative 'rental'

Car = Struct.new(:id, :price_per_day, :price_per_km)

data = JSON.parse(File.read('data.json'), symbolize_names: true)

rentals = data[:rentals].map do |rental_data|
  car_data = data[:cars].find { |c| c[:id] == rental_data[:car_id] }
  car = Car.new(car_data[:id], car_data[:price_per_day], car_data[:price_per_km])

  rental = Rental.new(rental_data[:id],
                      car,
                      Date.parse(rental_data[:start_date]),
                      Date.parse(rental_data[:end_date]),
                      rental_data[:distance],
                      deductible_reduction: rental_data[:deductible_reduction])

  actions = rental.payable.map do |actor, amount|
    { who: actor,
      type: amount < 0 ? 'debit' : 'credit',
      amount: amount.abs }
  end

  { id: rental.id,
    actions: actions }
end

File.open('output.json', 'w') do |f|
  f.puts(JSON.pretty_generate({ rentals: rentals }))
end
