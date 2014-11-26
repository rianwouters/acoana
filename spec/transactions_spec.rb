require 'spec_helper'
require 'transactions'

describe Transactions do
  describe "#from_csv" do
    subject { described_class.from_csv('spec/fixtures/transactions.csv') }

    it 'imports all transactions excluding the header' do
      puts described_class

      expect(subject.length).to equal 9
    end

    it 'imports the transaction date' do
      expect(subject[0].date()).to eql Date.new(2014,11,20)
    end
  end
end

describe Transaction do
  describe "#from_csv" do
    let(:addorwithdraw) { 'Bij' }
    let(:kind) { 'ipsum' }
    let(:code) { 'sit' }
    let(:description) { 'amet' }
    let(:name) { 'lorem' }
    let(:values) { [
      '20141120',
      name,
      'NL71 INGB 0006 0827 76',
      '569988888',
      code,
      addorwithdraw,
      '46,18',
      kind,
      description
    ] }
    subject { described_class.from_csv(values)  }

    fit 'imports the correct transaction data' do
      expect(subject.date).to eql Date.new(2014,11,20)
      expect(subject.name).to eql 'lorem'
      expect(subject.kind).to eql 'ipsum'
      expect(subject.account).to eql 'NL71INGB0006082776'
      expect(subject.contra_account).to eql '569988888'
      expect(subject.code).to eql 'sit'
      expect(subject.description).to eql 'amet'
      expect(subject.card_number).to be_nil
      expect(subject.amount).to eql(46.18)
    end

    context 'withdrawals' do
      let(:addorwithdraw) { 'Af' }
      it 'imports a negative transaction amount' do
        expect(subject.amount).to eql(-46.18)
      end
    end

    context 'transaction description has \'GT\' format' do
      let(:description) { 'Naam: dolorOmschrijving: 0062542185600891IBAN: NL28RBOS0569988888' }
      it 'imports the correct transaction data' do
        expect(subject.name).to eql 'dolor'
        expect(subject.description).to eql '0062542185600891'
        expect(subject.contra_account).to eql 'NL28RBOS0569988888'
      end
    end

    context 'transaction description has \'BA\' format 1' do
      let(:description) { 'Pasvolgnr:021 17-11-2014 18:30Transactie:92G1S9 Term:RW9VM8' }
      it 'imports the correct transaction data' do
        expect(subject.name).to eql 'lorem'
        expect(subject.card_number).to eql '021'
        expect(subject.timestamp).to eql DateTime.new(2014, 11, 17, 18, 30)
        expect(subject.id).to eql '92G1S9'
        expect(subject.terminal).to eql 'RW9VM8'
        expect(subject.description).to be_nil
      end
    end

    context 'transaction description has \'BA\' format 2' do
      let(:description) { 'BOERENBOND BRAZON / UDENHOUT    021 463841 165F58               ING BANK NV PASTRANSACTIES      ' }
      let(:name) {'17-11-14 18:30 BETAALAUTOMAAT    '}
      it 'imports the correct transaction data' do
        expect(subject.name).to eql 'BOERENBOND BRAZON / UDENHOUT'
        expect(subject.card_number).to eql '021'
        expect(subject.timestamp).to eql DateTime.new(2014, 11, 17, 18, 30)
        expect(subject.id).to eql '463841'
        expect(subject.terminal).to eql '165F58'
        expect(subject.description).to be_nil
      end

      context 'without a space between name and card number' do
        let(:description) { 'BOERENBOND BRAZON / UDENHOUT021 463841 165F58               ING BANK NV PASTRANSACTIES      ' }
        let(:name) {'17-11-14 18:30 BETAALAUTOMAAT    '}
        it 'imports the correct transaction data' do
          expect(subject.name).to eql 'BOERENBOND BRAZON / UDENHOUT'
          expect(subject.card_number).to eql '021'
          expect(subject.timestamp).to eql DateTime.new(2014, 11, 17, 18, 30)
          expect(subject.id).to eql '463841'
          expect(subject.terminal).to eql '165F58'
          expect(subject.description).to be_nil
        end
      end

      context 'with exchange currency and exchange rate' do
        let(:description) { 'BOERENBOND BRAZON / UDENHOUT021 463841 165F58 PLN 290,84 KOERS 4,17619 ING BANK NV PASTRANSACTIES      ' }
        let(:name) {'17-11-14 18:30 BETAALAUTOMAAT    '}
        it 'imports the correct transaction data' do
          expect(subject.name).to eql 'BOERENBOND BRAZON / UDENHOUT'
          expect(subject.card_number).to eql '021'
          expect(subject.timestamp).to eql DateTime.new(2014, 11, 17, 18, 30)
          expect(subject.id).to eql '463841'
          expect(subject.terminal).to eql '165F58'
          expect(subject.description).to be_nil
        end
      end

      context 'with date without time' do
        let(:description) { 'BOERENBOND BRAZON / UDENHOUT021 463841 165F58               ING BANK NV PASTRANSACTIES      ' }
        let(:name) {'17-11-14 BETAALAUTOMAAT    '}
        it 'imports the correct transaction data' do
          expect(subject.name).to eql 'BOERENBOND BRAZON / UDENHOUT'
          expect(subject.card_number).to eql '021'
          expect(subject.timestamp).to eql Date.new(2014, 11, 17)
          expect(subject.id).to eql '463841'
          expect(subject.terminal).to eql '165F58'
          expect(subject.description).to be_nil
        end
      end
    end

    context 'transaction description has \'GM\' format 1' do
      let(:description) { '03-06-2014 12:16 021     4660472' }
      it 'imports the correct transaction data' do
        expect(subject.name).to eql 'lorem'
        expect(subject.timestamp).to eql DateTime.new(2014, 06, 03, 12, 16)
        expect(subject.card_number).to eql '021'
        expect(subject.id).to eql '4660472'
      end
    end

    context 'transaction description has \'GM\' format 2' do
      let(:description) { 'BELFIUS35344104 / ANTWERPEN     021 86Z0I5                      AUTOMAATNUMMER BK353441         ING BANK NV PASTRANSACTIES' }
      let(:name) {'17-11-14 18:30 GELDAUTOMAAT    '}
      it 'imports the correct transaction data' do
        expect(subject.timestamp).to eql DateTime.new(2014, 11, 17, 18, 30)
        expect(subject.name).to eql 'GELDAUTOMAAT'
        expect(subject.description).to eql 'BELFIUS35344104 / ANTWERPEN'
        expect(subject.card_number).to eql '021'
        expect(subject.id).to eql '86Z0I5'
        expect(subject.terminal).to eql 'BK353441'
      end
    end

    context 'transaction description has \'GM\' format 3' do
      let(:description) { 'CS, NA SADKACH 1 / CESKE BUDEJOV021 691505 KOSTEN EUR 2,25      CZK 2.000,00 KOERS 27,5199      ING BANK NV PASTRANSACTIES     ' }
      it 'imports the correct transaction data' do
        expect(subject.description).to eql 'CS, NA SADKACH 1 / CESKE BUDEJOV'
        expect(subject.card_number).to eql '021'
        expect(subject.id).to eql '691505'
        expect(subject.exchange_cost).to eql 2.25
        expect(subject.exchange_currency).to eql 'CZK'
        expect(subject.exchange_amount).to eql 2000.0
        expect(subject.exchange_rate).to eql 27.5199
      end
    end

    context 'transaction description has \'IC\' SEPA format' do
      let(:description) { 'SEPA Incasso, doorlopendIBAN: NL54INGB0000000503Naam: NUON CCCKenmerk: R-515401574830Omschrijving: 515401574830 BTW           40,22 KLANTNR 22201301 CRN 3009310257 termijn nov 2014 Neereindseweg 28 5091 RD OOMandaat:M011000002316782Crediteur:NL43B2C091055420000' }
      it 'imports the correct transaction data' do
        expect(subject.collection_type).to eql 'doorlopend'
        expect(subject.contra_account).to eql 'NL54INGB0000000503'
        expect(subject.name).to eql 'NUON CCC'
        expect(subject.id).to eql 'R-515401574830'
        expect(subject.description).to eql '515401574830 BTW 40,22 KLANTNR 22201301 CRN 3009310257 termijn nov 2014 Neereindseweg 28 5091 RD OO'
        expect(subject.mandate).to eql 'M011000002316782'
        expect(subject.creditor).to eql 'NL43B2C091055420000'
      end
    end

    context 'transaction description has \'IC\' format' do
      let(:name) { 'SEPA Incasso, doorlopend' }
      let(:description) { 'IBAN: NL54INGB0000000503Naam: NUON CCCKenmerk: R-515401574830Omschrijving: 515401574830 BTW           40,22 KLANTNR 22201301 CRN 3009310257 termijn nov 2014 Neereindseweg 28 5091 RD OOMandaat:M011000002316782Crediteur:NL43B2C091055420000' }
      it 'imports the correct transaction data' do
        expect(subject.collection_type).to eql 'doorlopend'
        expect(subject.contra_account).to eql 'NL54INGB0000000503'
        expect(subject.name).to eql 'NUON CCC'
        expect(subject.id).to eql 'R-515401574830'
        expect(subject.description).to eql '515401574830 BTW 40,22 KLANTNR 22201301 CRN 3009310257 termijn nov 2014 Neereindseweg 28 5091 RD OO'
        expect(subject.mandate).to eql 'M011000002316782'
        expect(subject.creditor).to eql 'NL43B2C091055420000'
      end
    end
  end

end
