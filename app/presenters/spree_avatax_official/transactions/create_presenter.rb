module SpreeAvataxOfficial
  module Transactions
    class CreatePresenter
      def initialize(order:, transaction_type:, transaction_code: order.number)
        @order            = order
        @transaction_type = transaction_type
        @transaction_code = transaction_code
      end

      # Based on: https://developer.avalara.com/api-reference/avatax/rest/v2/models/CreateTransactionModel/
      def to_json # rubocop:disable Metrics/MethodLength
        {
          type:          transaction_type,
          code:          transaction_code,
          referenceCode: order.number,
          companyCode:   company_code,
          date:          formatted_date(order_date),
          customerCode:  order.email,
          addresses:     addresses_payload,
          lines:         items_payload,
          commit:        completed?(order),
          discount:      order.avatax_discount_amount
        }
      end

      delegate :avatax_ship_from_address, to: :order

      private

      attr_reader :order, :transaction_type, :transaction_code

      def company_code
        order.store.try(:avatax_company_code) || SpreeAvataxOfficial::Config.company_code
      end

      def formatted_date(date)
        date.strftime('%Y-%m-%d')
      end

      def order_date
        order.completed_at || order.updated_at
      end

      def ship_from_payload
        SpreeAvataxOfficial::AddressPresenter.new(address: avatax_ship_from_address, address_type: 'ShipFrom').to_json
      end

      def ship_to_payload
        SpreeAvataxOfficial::AddressPresenter.new(address: order.tax_address, address_type: 'ShipTo').to_json
      end

      def addresses_payload
        ship_from_payload.merge(ship_to_payload)
      end

      def items_payload
        order.taxable_items.map { |item| SpreeAvataxOfficial::ItemPresenter.new(item: item).to_json }
      end

      def completed?(order)
        order.completed_at.present?
      end
    end
  end
end