ruby
FactoryBot.define do
  factory :bank_account do
    sequence(:account_number) { |n| "10000#{n}" }
    customer_name { Faker::Name.name }
    account_type { %w[Savings Current].sample }
    balance { Faker::Number.decimal(l_digits: 4, r_digits: 2) }
    IFSC_code { Faker::Bank.swift_bic[0..3] + "0" + Faker::Number.number(digits: 6) }
  end
end