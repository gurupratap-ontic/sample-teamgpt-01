class BankAccount < ApplicationRecord
  validates :customer_name, presence: true
  validates :account_number, presence: true, uniqueness: true
  validates :account_type, presence: true, inclusion: { in: %w[Savings Current] }
  validates :balance, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :IFSC_code, presence: true
end
