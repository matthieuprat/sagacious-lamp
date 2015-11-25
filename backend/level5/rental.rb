require 'date'

Rental = Struct.new(:id, :car, :start_date, :end_date, :distance, :options) do
  def days
    1 + (end_date - start_date).to_i
  end

  def discount
    [
      [days -  1, 0].max * 0.1 * car.price_per_day, # 10% off after the 1st day.
      [days -  4, 0].max * 0.2 * car.price_per_day, # An aditionnal 20% off after the 4th day.
      [days - 10, 0].max * 0.2 * car.price_per_day, # An aditionnal 20% off after the 10th day.
    ].reduce(:+).round
  end

  def price
    car.price_per_day * days - discount + car.price_per_km * distance
  end

  def commission
    (price * 0.3).round
  end

  def insurance_fee
    (commission * 0.5).round
  end

  def assistance_fee
    days * 100
  end

  def drivy_fee
    commission - insurance_fee - assistance_fee
  end

  def deductible_reduction
    options[:deductible_reduction] ? days * 400 : 0
  end

  def payable
    { driver:     - price - deductible_reduction,
      owner:      price - commission,
      insurance:  insurance_fee,
      assistance: assistance_fee,
      drivy:      drivy_fee + deductible_reduction }
  end
end
