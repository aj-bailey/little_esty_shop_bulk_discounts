require "rails_helper"

RSpec.describe "Merchant Bulk Discount New Page" do
  before(:each) do
    stub_holidays_request
  end
  
  context "User Story 2" do
    describe 'As a Merchant' do
      describe 'When I visit the bulk discount new page' do
        before(:each) do
          @merchant_1 = Merchant.create!(name: 'Hair Care')
    
          visit new_merchant_bulk_discount_path(@merchant_1)
        end

        it "can see a form to add a new discount, and when I submit a new form, 
          I'm redirected to the bulk discount index page with the new discount" do

          within("#bulk_discount_form") {
            expect(page).to have_field(:bulk_discount_quantity_threshold)
            expect(page).to have_field(:bulk_discount_percentage_discount)
            expect(page).to have_button("Create Bulk discount")

            fill_in :bulk_discount_quantity_threshold, with: 10
            fill_in :bulk_discount_percentage_discount, with: 20

            click_button "Create Bulk discount"
          }

          expect(current_path).to eq(merchant_bulk_discounts_path(@merchant_1))
          expect(page).to have_content("New bulk discount added")

          within("#bulk_discount-#{@merchant_1.bulk_discounts.first.id}") {
            expect(page).to have_link("##{@merchant_1.bulk_discounts.first.id}", href: merchant_bulk_discount_path(@merchant_1, @merchant_1.bulk_discounts.first))
            expect(page).to have_content("10 units")
            expect(page).to have_content("20%")
          }
        end

        it 'cannot submit a form if not all information is included and be redirected to new discount page' do
          within("#bulk_discount_form") {
            fill_in :bulk_discount_quantity_threshold, with: 10

            click_button "Create Bulk discount"
          }

          expect(current_path).to eq(merchant_bulk_discounts_path(@merchant_1))
          expect(page).to have_content("Invalid form: Unable to create Bulk Discount")
        end

        it 'cannot submit form if quantity threshold is not a positive integer' do
          within("#bulk_discount_form") {
            fill_in :bulk_discount_quantity_threshold, with: -1
            fill_in :bulk_discount_percentage_discount, with: 20

            click_button "Create Bulk discount"
          }

          expect(page).to have_content("Invalid form: Unable to create Bulk Discount")

          within("#bulk_discount_form") {
            fill_in :bulk_discount_quantity_threshold, with: "one"
            fill_in :bulk_discount_percentage_discount, with: 20

            click_button "Create Bulk discount"
          }

          expect(page).to have_content("Invalid form: Unable to create Bulk Discount")
        end

        it 'cannot submit form if percentage discount is not between 1-99' do
          within("#bulk_discount_form") {
            fill_in :bulk_discount_quantity_threshold, with: 10
            fill_in :bulk_discount_percentage_discount, with: 101

            click_button "Create Bulk discount"
          }

          expect(page).to have_content("Invalid form: Unable to create Bulk Discount")
        end
      end
    end
  end
end