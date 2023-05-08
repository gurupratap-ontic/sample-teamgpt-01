
```ruby
namespace :import do
  desc 'Import bank accounts from a CSV file'
  task :bank_accounts, [:file_path] => :environment do |_task, args|
    file_path = args[:file_path]
    importer = BankAccountImporter.new(file_path)
    importer.import
    puts "Import completed with the following errors:" if importer.error_log.any?
    puts importer.error_log.join("\n")
  end
end
```
#####