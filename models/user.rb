class User < ActiveRecord::Base
  def create
    super
    this.level = 1
    this.save
  end
end
