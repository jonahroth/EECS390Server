class User < ActiveRecord::Base
  def create
    super
    this.level = 1
    this.date_created = Date.now
    this.last_signed_in = Date.now
    this.save
  end
end
