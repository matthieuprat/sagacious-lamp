class Payable < Hash
  def +(other)
    payable = (self.keys + other.keys).map do |actor|
      amount = (self[actor] || 0) + (other[actor] || 0)
      [actor, amount]
    end
    Payable[payable]
  end

  def -(other)
    self + Payable[other.map { |k, v| [k, -v] }]
  end

  def to_actions
    map do |actor, amount|
      { who: actor,
        type: amount < 0 ? 'debit' : 'credit',
        amount: amount.abs }
    end
  end
end
