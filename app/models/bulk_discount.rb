class BulkDiscount < ApplicationRecord
  belongs_to :merchant

  validates_presence_of :quantity_threshold, :percentage_discount

  validates_numericality_of :quantity_threshold, only_integer: true
  validates_numericality_of :quantity_threshold, greater_than: 0

  validates_numericality_of :quantity_threshold, only_integer: true
  validates_numericality_of :percentage_discount, less_than: 100
  validates_numericality_of :percentage_discount, greater_than_or_equal_to: 1

  def pending_invoice?
    self.merchant.invoices.where(status: "in progress").exists?
  end
end
