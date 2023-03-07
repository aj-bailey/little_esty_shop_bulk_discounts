class Admin::InvoicesController < ApplicationController
  before_action :set_invoice, only: [:show, :edit, :update]
  def index
    @invoices = Invoice.all
  end

  def show
  end

  def edit
  end

  def update
    add_invoice_item_discounts(@invoice)

    @invoice.update(invoice_params)
    flash.notice = 'Invoice Has Been Updated!'
    redirect_to admin_invoice_path(@invoice)
  end

  private
  def set_invoice
    @invoice = Invoice.find(params[:id])
  end

  def invoice_params
    params.require(:invoice).permit(:status)
  end

  def add_invoice_item_discounts(invoice)
    invoice.invoice_items.each do |invoice_item|
      discount = invoice_item.applied_discount

      if discount
        invoice_item.update!(discount_percentage: discount.percentage_discount)
      else
        invoice_item.update!(discount_percentage: 0)
      end
    end
  end
end