module SpreeAvataxOfficial
  module Transactions
    class PartialRefundPresenter < CreatePresenter
      def initialize(order:, refund_items:, transaction_code:)
        @order            = order
        @refund_items     = refund_items
        @transaction_code = transaction_code
        @transaction_type = SpreeAvataxOfficial::Transaction::RETURN_INVOICE
      end

      private

      attr_reader :refund_items

      def items_payload
        refund_items.map do |item, (quantity, amount)|
          SpreeAvataxOfficial::ItemPresenter.new(
            item:            item,
            custom_quantity: quantity,
            custom_amount:   amount
          ).to_json
        end
      end
    end
  end
end