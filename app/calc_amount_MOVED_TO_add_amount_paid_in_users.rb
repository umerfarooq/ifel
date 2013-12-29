class CalcAmount < ActiveRecord::Base
  User.all.each do |user|
    user.amount_paid = user.transaction_logs.collect {|tr| tr.amount}.sum
    user.save
  end
end