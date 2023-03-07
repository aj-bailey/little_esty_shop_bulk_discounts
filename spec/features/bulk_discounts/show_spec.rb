require "rails_helper"

RSpec.describe "Merchant Bulk Discount Show Page" do
  before(:each) do 
    stub_holidays_request
    
    @merchant_1 = Merchant.create!(name: 'Hair Care')
  
    @bulk_discount_1 = BulkDiscount.create!(merchant: @merchant_1, quantity_threshold: 5, percentage_discount: 15)

    visit merchant_bulk_discount_path(@merchant_1, @bulk_discount_1)
  end

  context "User Story 4" do
    describe 'As a merchant' do
      describe "When I visit my bulk discount show page" do
        it "can see the bulk discount's quantity threshold and percentage discount" do
          expect(page).to have_content("Bulk Discount ID: #{@bulk_discount_1.id}")
          expect(page).to have_content("Quantity Threshold: 5 units")
          expect(page).to have_content("Percentage Discount: 15%")
        end
      end
    end
  end

  context "User Story 5" do
    describe "As a merchant" do
      describe "When I visit my bulk discount show page" do
        it "can see a link to edit the bulk discount and when clicked, am taken to a new page where I can edit the discount" do
          expect(page).to have_link("Edit Discount", href: edit_merchant_bulk_discount_path(@merchant_1, @bulk_discount_1))

          click_link "Edit Discount"

          expect(current_path).to eq(edit_merchant_bulk_discount_path(@merchant_1, @bulk_discount_1))
        end
      end
    end
  end

  context 'Extension - bulk discount actions disabled when an invoice is pending' do
    describe 'As a merchant' do
      describe 'When I visit my bulk discount show page' do
        it 'cannot delete a bulk discount with an associated pending invoice' do
          customer = Customer.create!(first_name: 'Joey', last_name: 'Smith')
          pending_invoice = Invoice.create!(customer: customer, status: 1)
          item_1 = Item.create!(name: "Shampoo", description: "This washes your hair", unit_price: 10, merchant_id: @merchant_1.id, status: 1)
          invoice_item_1 = InvoiceItem.create!(invoice: pending_invoice, item: item_1, quantity: 20, unit_price: 5, status: 1)

          click_link "Edit Discount"

          expect(current_path).to eq(merchant_bulk_discount_path(@merchant_1, @bulk_discount_1))
          expect(page).to have_content("Unable to Edit Discount: This discount currently belongs to a pending invoice")
        end
      end
    end
  end
end