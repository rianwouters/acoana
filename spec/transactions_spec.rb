require 'spec_helper'
require 'transactions'

describe Transactions do
   describe :import_csv do
     subject { Transactions.import_csv('spec/fixtures/transactions.csv') }

     it 'imports all transactions excluding the header' do
       expect(subject.length).to equal 9
     end

   end
end

