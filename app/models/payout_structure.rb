class PayoutStructure < ActiveRecord::Base
  has_many :payouts, class_name: PayoutStructurePayout

  class PayoutAmount
    attr_accessor :payout
    attr_accessor :amount
  end

  def calculate_amounts(pool)
    payout_amounts = []
    self.payouts.each do |payout|
      payout_amount = PayoutAmount.new
      payout_amount.payout = payout
      payout_amount.amount = pool * payout.percent
      payout_amounts.push payout_amount
    end
    payout_amounts
  end
end
