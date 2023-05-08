
```ruby
class BankAccount < ActiveRecord::Base
  validates :customer_name, presence: true
  validates :account_number, presence: true, uniqueness: true
  validates :account_type, presence: true, inclusion: { in: %w[savings current] }
  validates :balance, presence: true, numericality: true
  validates :IFSC_code, presence: true
end
```
#####