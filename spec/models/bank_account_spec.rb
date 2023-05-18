ruby
require 'rails_helper'

RSpec.describe BankAccount, type: :model do
  it { should validate_presence_of(:customer_name) }
  it { should validate_presence_of(:account_number) }
  it { should validate_uniqueness_of(:account_number) }
  it { should validate_presence_of(:account_type) }
  it { should validate_inclusion_of(:account_type).in_array(%w[Savings Current]) }
  it { should validate_presence_of(:balance) }
  it { should validate_numericality_of(:balance).is_greater_than_or_equal_to(0) }
  it { should validate_presence_of(:IFSC_code) }
  it { should allow_value('ABCD0123456').for(:IFSC_code) }
  it { should_not allow_value('ABCD123456').for(:IFSC_code) }
end