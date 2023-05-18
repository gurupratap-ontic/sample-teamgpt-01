class BankAccount < ApplicationRecord
  validates :customer_name, presence: true
  validates :account_number, presence: true, uniqueness: true
  validates :account_type, presence: true
  validates :balance, presence: true
  validates :IFSC_code, presence: true
end
