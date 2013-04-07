class Video
  include Mongoid::Document

  attr_accessible :_id,:t,:u,:k,:v,:f,:ch,:d,:du,:c
  field :_id,	:type => String
  field :t,	:type => String
  field :u,	:type => String
  field :k,	:type => Array
  field :v,	:type => Integer
  field :f,	:type => Integer
  field :ch,	:type => String
  field :d,	:type => String
  field :du,	:type => Integer
  field :c,	:type => String
end
