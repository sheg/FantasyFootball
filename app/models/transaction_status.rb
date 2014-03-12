class TransactionStatus < ActiveRecord::Base
  has_many :team_transactions

  $transaction_statuses = TransactionStatus.all.to_a unless $transaction_statuses

  def self.COMPLETED
    $transaction_statuses.find { |a| a.name == 'completed' }
  end

  def self.PENDING
    $transaction_statuses.find { |a| a.name == 'pending' }
  end

  def self.CANCELLED
    $transaction_statuses.find { |a| a.name == 'cancelled' }
  end

  def self.REJECTED
    $transaction_statuses.find { |a| a.name == 'rejected' }
  end
end
