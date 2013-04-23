class Stream
  include Mongoid::Document
  
  attr_accessible :_id,:bw,:du,:mw,:cs,:v,:d,:l,:w
  field :_id,		:type => Hash
  field :bw,		:type => Hash
  field :du,		:type => Hash
  field :mw,		:type => Hash
  field :cs,		:type => Hash
  field :v,		   :type => Array
  field :l,       :type => Hash
  field :d,       :type => Hash
  field :w,       :type => Array
end
