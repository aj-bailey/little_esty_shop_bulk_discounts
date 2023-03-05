require "rails_helper"

RSpec.describe "Merchant Bulk Discount Edit Page" do
  before(:each) do
    stub_holidays_request
    
    @merchant_1 = Merchant.create!(name: 'Hair Care')
    
    @bulk_discount_1 = BulkDiscount.create!(merchant: @merchant_1, quantity_threshold: 5, percentage_discount: 15)
    
    visit edit_merchant_bulk_discount_path(@merchant_1, @bulk_discount_1)
  end

  context "User Story 5" do
    describe "As a merchant" do
      describe "When I visit my bulk discount show page" do
        it 'can see the pre-populated attributes in the edit form' do
          expect(page).to have_field(:bulk_discount_quantity_threshold, with: 5)
          expect(page).to have_field(:bulk_discount_percentage_discount, with: 15)
        end

        it "can change any/all of the information, click submit, be redirected to the show page and see the updated discount" do
          fill_in :bulk_discount_quantity_threshold, with: 10
          fill_in :bulk_discount_percentage_discount, with: 10

          click_button "Update Bulk discount"
          
          expect(current_path).to eq(merchant_bulk_discount_path(@merchant_1, @bulk_discount_1))

          expect(page).to have_content("10 units")
          expect(page).to have_content("10%")

          expect(page).to have_content("Bulk Discount Edited")
        end
        
        it 'cannot submit a form if not all information is included and be redirected to new discount page' do
          within("#bulk_discount_form") {
            fill_in :bulk_discount_quantity_threshold, with: ""

            click_button "Update Bulk discount"
          }

          expect(current_path).to eq(merchant_bulk_discount_path(@merchant_1, @bulk_discount_1))
          expect(page).to have_content("Invalid form: Unable to update Bulk Discount")
        end

        it 'cannot submit form if quantity threshold is not a positive integer' do
          within("#bulk_discount_form") {
            fill_in :bulk_discount_quantity_threshold, with: -1
            fill_in :bulk_discount_percentage_discount, with: 20

            click_button "Update Bulk discount"
          }

          expect(page).to have_content("Invalid form: Unable to update Bulk Discount")

          within("#bulk_discount_form") {
            fill_in :bulk_discount_quantity_threshold, with: "one"
            fill_in :bulk_discount_percentage_discount, with: 20

            click_button "Update Bulk discount"
          }

          expect(page).to have_content("Invalid form: Unable to update Bulk Discount")
        end

        it 'cannot submit form if percentage discount is not between 1-99' do
          within("#bulk_discount_form") {
            fill_in :bulk_discount_quantity_threshold, with: 10
            fill_in :bulk_discount_percentage_discount, with: 101

            click_button "Update Bulk discount"
          }

          expect(page).to have_content("Invalid form: Unable to update Bulk Discount")
        end
      end
    end
  end
end