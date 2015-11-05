class User < ActiveRecord::Base
  has_many :user_packages
  has_many :packages, through: :user_packages
  validates_uniqueness_of :username
  def new
    super
  end
end
