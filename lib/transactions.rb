require 'csv'

class Transactions

  def self.import_csv(filepath)
    CSV.read(filepath, headers: true)
  end

end
