class UserPackage < ActiveRecord::Base
  belongs_to :user
  belongs_to :package
  
  def create
    super
  end
end
