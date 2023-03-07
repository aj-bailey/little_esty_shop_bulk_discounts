class Invoice < ApplicationRecord
  validates_presence_of :status,
                        :customer_id

  belongs_to :customer
  has_many :transactions
  has_many :invoice_items
  has_many :items, through: :invoice_items
  has_many :merchants, through: :items
  has_many :bulk_discounts, through: :merchants

  enum status: [:cancelled, 'in progress', :completed]

  def total_revenue
    invoice_items.sum("unit_price * quantity")
  end

  def total_merchant_revenue(merchant)
    invoice_items.joins(:item)
    .select("invoice_items.*, items.merchant_id")
    .where("items.merchant_id = ?", merchant.id)
    .sum("invoice_items.unit_price * invoice_items.quantity")
  end

  def total_discounted_revenue
    InvoiceItem.from(
      invoice_items.joins(:bulk_discounts)
      .select("invoice_items.*, max(bulk_discounts.percentage_discount * invoice_items.quantity * invoice_items.unit_price / 100 ) as max_discount")
      .where("invoice_items.quantity >= bulk_discounts.quantity_threshold")
      .group(:id)
    )
    .sum("max_discount")
  end

  def total_merchant_discounted_revenue(merchant)
    # binding.pry
    InvoiceItem.from(
      invoice_items.joins(:bulk_discounts)
      .select("invoice_items.*, max(bulk_discounts.percentage_discount * invoice_items.quantity * invoice_items.unit_price / 100 ) as max_discount")
      .where("invoice_items.quantity >= bulk_discounts.quantity_threshold AND bulk_discounts.merchant_id = ?", merchant.id )
      .group(:id)
    )
      .sum("max_discount")
  end
end
