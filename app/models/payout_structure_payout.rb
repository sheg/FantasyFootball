class PayoutStructurePayout < ActiveRecord::Base
  belongs_to :payout_structure

  def percent_number
    return 0 unless percent
    (percent * 100).round
  end

  def total_percent
    total = 0
    payout_structure = PayoutStructure.includes(:payouts).find_by(id: payout_structure_id) unless payout_structure
    total = payout_structure.payouts.where.not(id: id).sum(:percent) if payout_structure and payout_structure.payouts
    (total * 100).round
  end

  before_save :validate_percentages
  before_update :validate_percentages

  def validate_percentages
    total = total_percent
    current = percent_number
    raise "Unable to save #{percent_number}% payout, total percentage cannot exceed 100% (currently at #{total_percent}%)" if total + current > 100
  end
end
