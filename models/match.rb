class Match < ActiveRecord::Base
  has_many :match_participants
  def new
    super
  end
end
