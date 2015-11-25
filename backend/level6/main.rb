require 'json'
require_relative 'rental'
require_relative 'payable'

Car = Struct.new(:id, :price_per_day, :price_per_km)

data = JSON.parse(File.read('data.json'), symbolize_names: true)

rental_modifications = data[:rental_modifications].map do |modification_data|
  rental_data = data[:rentals].find { |r| r[:id] == modification_data[:rental_id] }

  car_data = data[:cars].find { |c| c[:id] == rental_data[:car_id] }
  car = Car.new(car_data[:id], car_data[:price_per_day], car_data[:price_per_km])

  rental = Rental.new(rental_data[:id],
                      car,
                      Date.parse(rental_data[:start_date]),
                      Date.parse(rental_data[:end_date]),
                      rental_data[:distance],
                      deductible_reduction: rental_data[:deductible_reduction])

  modified_rental = rental.dup
  modified_rental.start_date = Date.parse(modification_data[:start_date]) if modification_data[:start_date]
  modified_rental.end_date   = Date.parse(modification_data[:end_date])   if modification_data[:end_date]
  modified_rental.distance   = modification_data[:distance]               if modification_data.include?(:distance)

  { id: modification_data[:id],
    rental_id: rental.id,
    actions: (Payable[modified_rental.payable] - rental.payable).to_actions }
end

File.open('output.json', 'w') do |f|
  f.puts(JSON.pretty_generate({ rental_modifications: rental_modifications }))
end
