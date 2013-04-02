class Stream
  include Mongoid::Document

  field :_id,		:type => Hash
  field :bw,		:type => Array
  field :du,		:type => Hash
  field :mw,		:type => Array
  field :cs,		:type => Array
  field :v,		:type => Array

end
