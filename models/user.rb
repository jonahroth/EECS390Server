class User < ActiveRecord::Base
  def create
    super
    this.level = 1
    this.date_created = DateTime.now
    this.last_signed_in = DateTime.now
    this.save
  end
end
