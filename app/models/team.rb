class Team < ActiveRecord::Base
  belongs_to :league
  belongs_to :user

  #validates :user_id, :uniqueness => { scope: :league_id, message: "Cannot own more than one team per league" }
  validates :name, :uniqueness => { :case_sensitive => false }

end