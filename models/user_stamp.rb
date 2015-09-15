class UserStamp < ActiveRecord::Base
  def create
    super
    this.date_purchased = Date.now
    this.save
  end
end
