module Yesmail
  class Master
    attr_accessor :api_id, :api_transaction_id

    def path
      '/masters'
    end

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