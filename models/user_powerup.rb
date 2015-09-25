class UserPowerup < ActiveRecord::Base
  belongs_to :user
  belongs_to :powerup

  def create
    super
  end
end
