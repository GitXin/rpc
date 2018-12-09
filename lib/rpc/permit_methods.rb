module Rpc
  module PermitMethods
    COMPLETE = [
      :find, :take, :take!, :first, :first!, :last, :last!, :exists?, :any?, :many?,
      :count, :average, :minimum, :maximum, :sum, :calculate,
      :all
    ]
    UNCOMPLETE = [
      :select, :group, :order, :except, :reorder, :limit, :offset, :joins,
      :where, :rewhere, :preload, :eager_load, :includes, :from, :lock, :readonly,
      :having, :create_with, :uniq, :distinct, :references, :none, :unscope
    ]
  end
end
