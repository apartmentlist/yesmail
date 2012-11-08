# This class is used to represent a single transaction with Yesmail
module Yesmail
  class Master
    # @attribute api_id [String] the master_id that identifies
    #     your account with Yesmail
    # @attribute api_transaction_id [String] the transactionID
    #     that ids this transaction with Yesmail
    attr_accessor :api_id, :api_transaction_id

    def path
      '/masters'
    end

    # @return [Hash] represents the masterId and transactionID
    #     part of the outgoing JSON request to Yesmail
    def subscriber_message_data
      {
        masterId: api_id,
        attributes: {
          attributes: [
              { name: 'transactionID', value: api_transaction_id }
          ]
        }
      }
    end
  end
end
