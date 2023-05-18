namespace :import do
  desc 'Import bank account data from a CSV file'
  task :bank_accounts, [:file_path] => :environment do |_task, args|
    if args[:file_path].nil?
      puts 'Usage: rake import:bank_accounts[file_path]'
      exit 1
    end

    begin
      importer = BankAccountImporter.new
      summary = importer.import_from_csv(args[:file_path])
      Rails.logger.info "Bank account data import completed successfully: #{summary[:total_records]} total records, #{summary[:skipped_records]} skipped records"
    rescue ArgumentError, MalformedCSVError => e
      Rails.logger.error "Failed to import bank account data: #{e.message}"
    end
  end
end
