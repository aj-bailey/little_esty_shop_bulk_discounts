require 'rails_helper'

RSpec.describe "Merchants Bulk Discounts Index" do
  context "User Story 1" do
    describe 'As a merchant' do
      describe 'When I visit my merchants bulk discounts index page' do
        before(:each) do 
          @merchant_1 = Merchant.create!(name: 'Hair Care')

          @bulk_discount_1 = BulkDiscount.create!(merchant: @merchant_1, quantity_threshold: 5, percentage_discount: 0.15)
          @bulk_discount_2 = BulkDiscount.create!(merchant: @merchant_1, quantity_threshold: 10, percentage_discount: 0.20)
          @bulk_discount_3 = BulkDiscount.create!(merchant: @merchant_1, quantity_threshold: 15, percentage_discount: 0.30)

          visit merchant_bulk_discounts_path(@merchant_1)
        end

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
end