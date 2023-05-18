namespace :bank_accounts do
  desc 'Import bank account data from a CSV file'
  task :import, [:file] => :environment do |_, args|
    file = args[:file]

    if file.nil?
      puts 'Please provide a CSV file as an argument'
      exit(1)
    end

    begin
      importer = BankAccountCsvImporter.new(file)
      importer.import
      puts 'Bank account data imported successfully'
    rescue => e
      puts "Error: #{e.message}"
      exit(1)
    end
  end
end
