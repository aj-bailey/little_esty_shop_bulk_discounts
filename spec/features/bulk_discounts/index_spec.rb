require 'rails_helper'

RSpec.describe "Merchants Bulk Discounts Index" do
  before(:each) do 
    stub_holidays_request
    
    @merchant_1 = Merchant.create!(name: 'Hair Care')
  
    @bulk_discount_1 = BulkDiscount.create!(merchant: @merchant_1, quantity_threshold: 5, percentage_discount: 15)
    @bulk_discount_2 = BulkDiscount.create!(merchant: @merchant_1, quantity_threshold: 10, percentage_discount: 20)
    @bulk_discount_3 = BulkDiscount.create!(merchant: @merchant_1, quantity_threshold: 15, percentage_discount: 30)
  
    visit merchant_bulk_discounts_path(@merchant_1)
  end

  context "User Story 1" do
    describe 'As a merchant' do
      describe 'When I visit my merchants bulk discounts index page' do

        it 'has links to my invoices, items and dashboard' do
          expect(page).to have_link("Dashboard", href: merchant_dashboard_index_path(@merchant_1) )
          expect(page).to have_link("Items", href: merchant_items_path(@merchant_1))
          expect(page).to have_link("Invoices", href: merchant_invoices_path(@merchant_1))
          expect(page).to have_link("Bulk Discounts", href: merchant_bulk_discounts_path(@merchant_1))
        end

        it 'can see all of my bulk discounts including their percentage discount, quantity threshold and link to its show page' do
          within("#bulk_discount-#{@bulk_discount_1.id}") { 
            expect(page).to have_link("##{@bulk_discount_1.id}", href: merchant_bulk_discount_path(@merchant_1, @bulk_discount_1))
            expect(page).to have_content("5 units")
            expect(page).to have_content("15%")
          }

          within("#bulk_discount-#{@bulk_discount_2.id}") { 
            expect(page).to have_link("##{@bulk_discount_2.id}", href: merchant_bulk_discount_path(@merchant_1, @bulk_discount_2))
            expect(page).to have_content("10 units")
            expect(page).to have_content("20%")
          }

          within("#bulk_discount-#{@bulk_discount_3.id}") { 
            expect(page).to have_link("##{@bulk_discount_3.id}", href: merchant_bulk_discount_path(@merchant_1, @bulk_discount_3))
            expect(page).to have_content("15 units")
            expect(page).to have_content("30%")
          }
        end
      end
    end
  end

  context 'User Story 2' do
    describe 'As a merchant' do
      describe 'When I visit my bulk discounts index' do
        it "can see a link to create a new discount and when clicked, I'm taken to a new page to add the discount" do
          expect(page).to have_link("New Discount", href: new_merchant_bulk_discount_path(@merchant_1))

          click_link "New Discount"

          expect(current_path).to eq(new_merchant_bulk_discount_path(@merchant_1))
        end
      end
    end
  end

  context 'User Story 3' do
    describe 'As a merchant' do
      describe 'When I visit my bulk discounts index' do
        it "can see a link next to each discount to delete it and when clicked, I'm redirected to the index page and no longer see the discount" do
          within("#bulk_discount-#{@bulk_discount_1.id}") {
            expect(page).to have_button("Delete Discount")

            click_button "Delete Discount"
          } 

          expect(current_path).to eq(merchant_bulk_discounts_path(@merchant_1))
          expect(page).to_not have_content("##{@bulk_discount_1.id}")
        end
      end
    end
  end

  context 'User Story 9' do
    describe 'As a merchant' do
      describe 'When I visit the discounts index page' do
        it 'can see a "Upcoming Holidays" section with the names and dates of the next three US holidays listed' do
          within("#next_three_holidays") {
            expect("Good Friday - 2023-04-07").to appear_before("Memorial Day - 2023-05-29")
            expect("Memorial Day - 2023-05-29").to appear_before("Juneteenth - 2023-06-19")
          }
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

          within("#bulk_discount-#{@bulk_discount_3.id}") { click_button "Delete Discount" }

          expect(current_path).to eq(merchant_bulk_discounts_path(@merchant_1))
          expect(page).to have_content("Unable to Delete Discount: This discount currently belongs to a pending invoice")
        end
      end
    end
  end
end