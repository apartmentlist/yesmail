# This class represents 1 person that will receive an email from Yesmail
# It currently supports the Send and Subscribe Composite API, and the
# Subscriber API.
#
# Key concepts:
#  * A "master" is an email campaign, containing an email template.
#  * A "subscriber" is an email recipient with many "attributes".  The one
#     mandatory attribute is "email" (the email address).  All other
#     attributes are determined by the master's template.
#
# URLs:
#   http://devcenter.infogroupinteractive.com/index.php/Special:UserLogin
#   http://devcenter.infogroupinteractive.com/index.php/List_of_Enterprise_Web_Services_APIs
#   http://devcenter.infogroupinteractive.com/index.php/Subscribe_and_Send_Composite_API
#   http://devcenter.infogroupinteractive.com/index.php/Glossary
#

require 'json'
require 'log_mixin'

module Yesmail
  class Subscriber
    include ::LogMixin

    # @attribute email [String] The email that will receive a Yesmail email
    # @attribute name [String] The name of the user
    # @attribute attribute_data [Hash] used for any extra data in the user
    #     attributes
    attr_accessor :email, :name, :user_id, :attribute_data

    def path
      '/subscribers'
    end

    def make_hash
      data_hash = {
        subscriptionState: Yesmail.configuration.subscription_state,
        division: { value: Yesmail.configuration.division },

        # inner list is [ {name: :attr1, value: 'val1'}, {name: ...}, ...]
        attributes: { attributes: [] }
      }

      data.each do |key, value|
        data_hash[:attributes][:attributes] << { name: key, value: value }
      end

      data_hash
    end

    def data
      @attribute_data ||= {}
      name_data = name.blank? ? {} : {
        firstName: first_name,
        lastName: last_name
      }
      
      {
        email: email
      }.merge(name_data).merge(attribute_data)
    end

    # These name methods aren't really safe. They might just blow up if the
    # name isn't formatted correctly.  (However, they work correctly if +name+
    # is a first name with no last name.)
    def first_name
      name.split(' ').first
    end

    def last_name
      name.split(' ')[1..-1].join(' ')
    end

    def handler
      @poster ||= Poster.new(Yesmail.configuration.username, Yesmail.configuration.password)
    end

    def api_create
      handler.post(make_hash, path)
    end

    def api_update
      user_id = self.user_id || get_user_id_from_email
      data_hash = make_hash
      #allowResubscribe must be true when resubscribing a subscriber
      data_hash[:allowResubscribe] = true
      handler.update(make_hash, path, user_id)
    end

    # Invoke api_get() and parse the response to determine the user ID, if any.
    # @return [Fixnum] the subscriber ID associated with the email address,
    #    or 0 if Yesmail does not know this email address.
    def get_user_id_from_email
      if user_id.nil?
        response = api_get
        match_data = response.match(%r[https://services\.yesmail\.com/enterprise/subscribers/(\d+)])
        match_data.present? ? match_data[1].to_i : 0
      end
    end

    # Return the raw XML response from attempting to retrieve this subscriber
    # via their email address.
    # @return [String] an XML response such as the following, on success:
    #  <?xml version="1.0"?>
    #  <yesws:uri xmlns:yesws="https://services.yesmail.com" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="https://services.yesmail.com docs/xsd/uri.xsd">https://services.yesmail.com/enterprise/subscribers/2266554</yesws:uri>
    #
    # Or a response such as the following on error:
    # <?xml version="1.0"?>
    # <yesws:error xmlns:yesws="https://services.yesmail.com" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="https://services.yesmail.com docs/xsd/error.xsd">
    # 	<yesws:trackingId>6fff6f05-e5ea-4667-a852-6ab9eeebbeeb</yesws:trackingId>
    #     <yesws:message>subscriber query had an empty result set.</yesws:message>    
    # </yesws:error>
    #
    def api_get
      handler.get({email: email}, path)
    end

    # Delete this subscriber by sending an HTTP DELETE to the target URL.
    # @return [String] the XML response from the server
    def api_remove
      data_hash = make_hash
      user_id = get_user_id_from_email
      delete_hash = { division: data_hash[:division][:value] }
      handler.remove(delete_hash, path, user_id)
    end

    # This will create all of the json from the data placed in this subscriber
    # and send it in the form of JSON to Yesmail's subscribe and send
    # composite API
    #
    # @param master [Yesmail::Master] the email campaign
    # @param side_table [Yesmail::SideTable] data to be stored in side table
    #    or nil if no side table data should be sent
    # @return [String] the XML response from the server
    def api_create_and_send(master, side_table = nil)
      data = { subscriber: make_hash }
      data[:subscriberMessage] =  master.subscriber_message_data
      data[:subscriber][:allowResubscribe] = true
      data[:sideTable] = side_table.payload_hash unless side_table.nil?

      path = '/composite/subscribeAndSend'
      attrs = data[:subscriber][:attributes][:attributes]
      # attrs has the form [ {name: :attr1, value: 'val1'}, {name: ...}, ...]
      email = attrs.select {|h| h[:name] == :email}.first[:value]
      master_id = master.subscriber_message_data[:masterId]
      info("Yesmail: subscribeAndSend #{email} to master #{master_id}")
      handler.post(data, path)
    end
  end
end
