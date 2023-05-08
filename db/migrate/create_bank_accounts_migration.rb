
```ruby
class CreateBankAccounts < ActiveRecord::Migration[6.1]
  def change
    create_table :bank_accounts do |t|
      t.string :customer_name, null: false
      t.string :account_number, null: false, unique: true
      t.string :account_type, null: false
      t.decimal :balance, null: false
      t.string :IFSC_code, null: false

      t.timestamps
    end
  end
end
```
#####