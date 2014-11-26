require 'csv'

class Transactions

  def self.from_csv(filepath)
    transactions = []
    CSV.foreach(filepath, headers: true) do |row|
      transactions << Transaction.from_csv(row)
    end
    transactions
  end

end

class Transaction

  attr_reader :date
  attr_reader :name
  attr_reader :account
  attr_reader :contra_account
  attr_reader :code
  attr_reader :amount
  attr_reader :kind
  attr_reader :description
  attr_reader :card_number
  attr_reader :timestamp
  attr_reader :id
  attr_reader :terminal
  attr_reader :exchange_cost
  attr_reader :exchange_currency
  attr_reader :exchange_amount
  attr_reader :exchange_rate
  attr_reader :mandate
  attr_reader :creditor
  attr_reader :collection_type


  def initialize(attrs)
    @date = attrs[:date]
    @name = attrs[:name]
    @account = attrs[:account]
    @contra_account = attrs[:contra_account]
    @code = attrs[:code]
    @amount = attrs[:amount]
    @kind = attrs[:kind]
    @description = attrs[:description]
    @card_number = attrs[:card_number]
    @timestamp = attrs[:timestamp]
    @id = attrs[:id]
    @terminal = attrs[:terminal]
    @exchange_cost = attrs[:exchange_cost]
    @exchange_currency = attrs[:exchange_currency]
    @exchange_amount = attrs[:exchange_amount]
    @exchange_rate = attrs[:exchange_rate]
    @mandate = attrs[:mandate]
    @creditor = attrs[:creditor]
    @collection_type = attrs[:collection_type]
  end

  def self.from_csv(values)
    attrs = { }
    attrs[:date]= Date.strptime(values[0],'%Y%m%d')
    attrs[:account] = values[2].split.join
    attrs[:contra_account] = values[3].split.join
    attrs[:code] = values[4]
    amount = self.parse_float(values[6])
    attrs[:amount] = values[5] == 'Af' ? -amount : amount
    attrs[:kind] = values[7]

    names_regexp =
      /(((?<timestamp_f2>\d{2}-\d{2}-\d{2}\s\d{2}:\d{2})|(?<timestamp_f3>\d{2}-\d{2}-\d{2}))\s((?<name>GELDAUTOMAAT|BETAALAUTOMAAT)))|\
      (SEPA\sIncasso,\s(?<collection_type>\S+))|\
      (?<name>.*)/x
    self.parse(values[1], names_regexp, attrs)

    values[8].gsub!(/\s+/, ' ')
    desc_regexp =
      /(Naam:\s(?<name>.*)Omschrijving:\s(?<description>.*)IBAN:\s(?<contra_account>.*))|\
      (Pasvolgnr:(?<card_number>\d{3})\s(?<timestamp_f1>\d{2}-\d{2}-\d{4}\s\d{2}:\d{2})Transactie:(?<id>\S*)\sTerm:(?<terminal>\S*))|\
      ((?<timestamp_f1>\d{2}-\d{2}-\d{4}\s\d{2}:\d{2})\s(?<card_number>\d{3})\s(?<id>\S*))|\
      ((?<description>.*)\s(?<card_number>\d{3})\s(?<id>\S*)\sAUTOMAATNUMMER\s(?<terminal>\S*)\sING\sBANK\sNV\sPASTRANSACTIES)|\
      ((|SEPA\sIncasso,\s(?<collection_type>\S+))IBAN:\s(?<contra_account>.*)Naam:\s(?<name>.*)Kenmerk:\s(?<id>\S*)Omschrijving:\s(?<description>.*)Mandaat:(?<mandate>.*)Crediteur:(?<creditor>.*))|\
      ((?<description>.*)(?<card_number>\d{3})\s(?<id>\S*)\sKOSTEN\sEUR\s(?<exchange_cost>\S*)\s(?<exchange_currency>\S*)\s(?<exchange_amount>\S*)\sKOERS\s(?<exchange_rate>\S*)\sING\sBANK\sNV\sPASTRANSACTIES)|\
      ((?<name>.*\w)\s*(?<card_number>\d{3})\s(?<id>\S*)\s(?<terminal>\S*)\s(|(?<exchange_currency>\S*)\s(?<exchange_amount>\S*)\sKOERS\s(?<exchange_rate>\S*)\s)INGi\sBANK\sNV\sPASTRANSACTIES)|\
      ((?<description>.*))/x
    self.parse(values[8], desc_regexp, attrs)

    [:exchange_cost, :exchange_amount, :exchange_rate].each do |key|
      attrs[key] = self.parse_float(attrs[key]) if attrs[key]
    end
    Transaction.new(attrs)
  end

  private

  def self.parse(value, regexp, attrs)
    value.gsub!(/\s+/, ' ')
    match = regexp.match(value)
    match.names.each do |name|
      if s = match[name.to_sym] then attrs[name.to_sym] = s end
    end
    attrs[:timestamp] = DateTime.strptime(attrs[:timestamp_f1], '%d-%m-%Y %H:%M') if attrs[:timestamp_f1]
    attrs[:timestamp] = DateTime.strptime(attrs[:timestamp_f2], '%d-%m-%y %H:%M') if attrs[:timestamp_f2]
    attrs[:timestamp] = Date.strptime(attrs[:timestamp_f3], '%d-%m-%y') if attrs[:timestamp_f3]
  end

  def self.parse_float(s)
    s.tr('.', '').tr(',','.').to_f
  end
end
