class Channel
  include Mongoid::Document
  attr_accessible :_id
  field :_id,	:type => String
end
