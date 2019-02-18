module SpreeAvataxOfficial
  module Transactions
    class RefundService < SpreeAvataxOfficial::Base
      def call(refundable:)
        refund_transaction(refundable).tap do |response|
          return request_result(response) do
            create_transaction(response['code'], order(refundable))
          end
        end
      end

      private

      def refund_transaction(refundable)
        client.refund_transaction(
          company_code,
          order(refundable).number,
          refund_model(refundable)
        )
      end

      def order(refundable)
        case refundable
        when ::Spree::ReturnAuthorization
          refundable.order
        when ::Spree::ReturnItem
          refundable.return_authorization.order
        end
      end

      def refund_model(refundable)
        case refundable
        when ::Spree::ReturnAuthorization
          ReturnAuthorizationPresenter.new(return_authorization: refundable).to_json
        when ::Spree::ReturnItem
          ReturnItemPresenter.new(return_item: refundable).to_json
        end
      end

      def create_transaction(code, order)
        SpreeAvataxOfficial::Transactions::SaveCodeService.call(
          code:  code,
          order: order,
          type:  SpreeAvataxOfficial::Transaction::RETURN_INVOICE
        )
      end
    end
  end
end