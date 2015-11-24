require 'json'
require 'date'

data = JSON.parse(File.read('data.json'), symbolize_names: true)

rentals = data[:rentals].map do |rental|
  car = data[:cars].find { |c| c[:id] == rental[:car_id] }
  days = 1 + (Date.parse(rental[:end_date]) - Date.parse(rental[:start_date])).to_i
  price = car[:price_per_day] * days + car[:price_per_km] * rental[:distance]

  { id: rental[:id], price: price }
end

File.open('output.json', 'w') do |f|
  f.puts(JSON.pretty_generate({ rentals: rentals }))
end
