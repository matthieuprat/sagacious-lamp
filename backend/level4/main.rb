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

  { id: rental.id,
    price: rental.price,
    options: {
      deductible_reduction: rental.deductible_reduction },
    commission: {
      insurance_fee: rental.insurance_fee,
      assistance_fee: rental.assistance_fee,
      drivy_fee: rental.drivy_fee } }
end

File.open('output.json', 'w') do |f|
  f.puts(JSON.pretty_generate({ rentals: rentals }))
end
