class Capture < ActiveRecord::Base
  belongs_to :client

  scope :active,   -> {where(archived: false)}
  scope :archived, -> {where(archived: true)}


end
