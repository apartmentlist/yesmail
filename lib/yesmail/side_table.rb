# This class handles the side table part of the outgoing JSON message to
# Yesmail
#
# According to the online API, the side table is structured as such:
#
# { sideTable: { tables: [ { name: 'your_table_name',
#    rows: { rows: [
#      { columns: { columns: [
#          { name: 'attribute_1', value: 'val1' }
#          { name: 'attribute_2', value: 'val2' }
#          ...
#          ]}}]}}]}}

module Yesmail
  class SideTable
    attr_accessor :table_name, :sort_id

    def initialize
      @sort_id = 0
    end

    def push_row(row)
      rows[:rows] << row
    end

    def rows
      @rows ||= { rows: [] }
    end

    # This probably the only method you need to call.
    def data_to_rows(data, subscriber = nil)
      #increment the sort id
      @sort_id += 1
      data.merge!({ email: subscriber.email })
      columns = { columns: [] }
      data.each do |key, value|
        columns[:columns] << { name: key, value: value}
      end
      columns = add_sort(columns)
      push_row({ columns: columns })
    end

    def add_sort(columns)
      columns[:columns] << { name: 'sortid', value: sort_id }
      columns
    end

    def payload_hash
      { tables: [ { name: table_name , rows:rows }  ] }
    end
  end
end
