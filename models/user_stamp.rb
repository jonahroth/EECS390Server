class UserStamp < ActiveRecord::Base
  def create
    super
    this.date_purchased = DateTime.now
    this.save
  end
end
