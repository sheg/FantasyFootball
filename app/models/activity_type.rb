class ActivityType < ActiveRecord::Base
  $activity_types = ActivityType.all.to_a unless $activity_types

  def self.DRAFT
    $activity_types.find { |a| a.name == 'draft' }
  end

  def self.ADD
    $activity_types.find { |a| a.name == 'add' }
  end

  def self.DROP
    $activity_types.find { |a| a.name == 'drop' }
  end

  def self.TRADE
    $activity_types.find { |a| a.name == 'trade' }
  end
end
