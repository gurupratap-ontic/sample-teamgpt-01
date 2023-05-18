require 'rails_helper'

RSpec.describe BankAccount, type: :model do
  it { should validate_presence_of(:customer_name) }
  it { should validate_presence_of(:account_number) }
  it { should validate_uniqueness_of(:account_number) }
  it { should validate_presence_of(:account_type) }
  it { should validate_presence_of(:balance) }
  it { should validate_presence_of(:IFSC_code) }
end
