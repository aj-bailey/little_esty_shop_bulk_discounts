require 'rails_helper'

RSpec.describe Invoice, type: :model do
  describe "validations" do
    it { should validate_presence_of :status }
    it { should validate_presence_of :customer_id }
  end

  describe "relationships" do
    it { should belong_to :customer }
    it { should have_many(:items).through(:invoice_items) }
    it { should have_many(:merchants).through(:items) }
    it { should have_many :transactions}
    it { should have_many(:bulk_discounts).through(:merchants) }
  end
  
  describe "instance methods" do
    before(:each) do
      @merchant1 = Merchant.create!(name: 'Hair Care')
      @item_1 = Item.create!(name: "Shampoo", description: "This washes your hair", unit_price: 10, merchant_id: @merchant1.id, status: 1)
      @item_8 = Item.create!(name: "Butterfly Clip", description: "This holds up your hair but in a clip", unit_price: 5, merchant_id: @merchant1.id)
      @customer_1 = Customer.create!(first_name: 'Joey', last_name: 'Smith')
      @invoice_1 = Invoice.create!(customer_id: @customer_1.id, status: 2, created_at: "2012-03-27 14:54:09")
      @ii_1 = InvoiceItem.create!(invoice_id: @invoice_1.id, item_id: @item_1.id, quantity: 9, unit_price: 10, status: 2)
      @ii_11 = InvoiceItem.create!(invoice_id: @invoice_1.id, item_id: @item_8.id, quantity: 12, unit_price: 6, status: 1)
    end

    it "total_revenue" do
      expect(@invoice_1.total_revenue).to eq(162)
    end

    describe '#total_merchant_revenue' do
      it 'returns all the revenue for a specific merchant on a invoice' do
        other_merchant = Merchant.create!(name: "Other Merchant")
        other_merchant_item = Item.create!(name: 'Other Merchant Item', description: "Fixes the repo", unit_price: 10, merchant: other_merchant, status: 1)
        invoice_item = InvoiceItem.create!(invoice: @invoice_1, item: other_merchant_item, quantity: 10, unit_price: 10, status: 2)

        expect(@invoice_1.total_merchant_revenue(@merchant1)).to eq(162)
      end
    end

    describe "#total_discounted_revenue" do
      it "returns no discounts if invoice_item quantity is below discount quantity threshold" do
        BulkDiscount.create!(merchant: @merchant1, quantity_threshold: 20, percentage_discount: 10)
        BulkDiscount.create!(merchant: @merchant1, quantity_threshold: 15, percentage_discount: 5)

        expect(@invoice_1.total_discounted_revenue).to eq(0)
      end

      it "returns total discounted revenue only for invoice_items with a quantity above the discount quantity threshold" do
        BulkDiscount.create!(merchant: @merchant1, quantity_threshold: 10, percentage_discount: 10)

        expect(@invoice_1.total_discounted_revenue).to eq(7.2)
      end

      it "returns unique discounts for each invoice_item based on their quantity and corresponding discount quantity thresholds" do
        BulkDiscount.create!(merchant: @merchant1, quantity_threshold: 5, percentage_discount: 10)
        BulkDiscount.create!(merchant: @merchant1, quantity_threshold: 10, percentage_discount: 20)

        expect(@invoice_1.total_discounted_revenue).to eq(23.4)
      end

      it 'returns the largest discount, regardless of quantity threshold' do
        BulkDiscount.create!(merchant: @merchant1, quantity_threshold: 5, percentage_discount: 20)
        BulkDiscount.create!(merchant: @merchant1, quantity_threshold: 12, percentage_discount: 10)

        expect(@invoice_1.total_discounted_revenue).to eq(32.4)
      end
    end

    describe '#total_discounted_merchant_revenue' do
      it "returns unique discounts for each invoice_item based on their quantity and corresponding discount quantity thresholds" do
        BulkDiscount.create!(merchant: @merchant1, quantity_threshold: 5, percentage_discount: 10)
        BulkDiscount.create!(merchant: @merchant1, quantity_threshold: 10, percentage_discount: 20)

        merchant_2 = Merchant.create!(name: 'Beard Care')
        merchant_2_item = Item.create!(name: "Shampoo", description: "This washes your beard hair", unit_price: 10, merchant_id: merchant_2.id, status: 1)
        InvoiceItem.create!(invoice_id: @invoice_1.id, item_id: merchant_2_item.id, quantity: 12, unit_price: 6, status: 1)
        BulkDiscount.create!(merchant: merchant_2, quantity_threshold: 10, percentage_discount: 20)

        expect(@invoice_1.total_merchant_discounted_revenue(@merchant1)).to eq(23.4)
      end
    end
  end
end
