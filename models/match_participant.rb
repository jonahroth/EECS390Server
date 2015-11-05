class MatchParticipant < ActiveRecord::Base
  belongs_to :user
  belongs_to :match

  def create
    super
  end
end
