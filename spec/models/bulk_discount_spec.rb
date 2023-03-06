require 'rails_helper'

RSpec.describe BulkDiscount, type: :model do
  describe 'relationships' do
    it { should belong_to :merchant }
  end

  describe 'validations' do
    it { should validate_presence_of :quantity_threshold }
    it { should validate_presence_of :percentage_discount }

    it { should validate_numericality_of(:quantity_threshold).only_integer }
    it { should validate_numericality_of(:quantity_threshold).is_greater_than(0) }

    it { should validate_numericality_of(:quantity_threshold).only_integer }
    it { should validate_numericality_of(:percentage_discount).is_greater_than_or_equal_to(1) }
    it { should validate_numericality_of(:percentage_discount).is_less_than(100) }
  end

  describe '#Instance Methods' do
    describe '#pending_invoice?' do
      before(:each) do
        @merchant_1 = Merchant.create!(name: 'Hair Care')
        @customer = Customer.create!(first_name: 'Joey', last_name: 'Smith')
        @bulk_discount_1 = BulkDiscount.create!(merchant: @merchant_1, quantity_threshold: 5, percentage_discount: 15)
        completed_invoice = Invoice.create!(customer: @customer, status: 2)
        @item_1 = Item.create!(name: "Shampoo", description: "This washes your hair", unit_price: 10, merchant_id: @merchant_1.id, status: 1)
        invoice_item_2 = InvoiceItem.create!(invoice: completed_invoice, item: @item_1, quantity: 20, unit_price: 5, status: 1)
 
      end
      it 'returns true if this bulk discount has a pending invoice' do
        pending_invoice = Invoice.create!(customer: @customer, status: 1)
        invoice_item_1 = InvoiceItem.create!(invoice: pending_invoice, item: @item_1, quantity: 20, unit_price: 5, status: 1)

        expect(@bulk_discount_1.pending_invoice?).to eq(true)
      end

      it 'returns false if this bulk discount does not have a pending invoice' do
        
        expect(@bulk_discount_1.pending_invoice?).to eq(false)
      end
    end
  end
end
