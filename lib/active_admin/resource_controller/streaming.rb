require 'csv'

module ActiveAdmin
  class ResourceController < BaseController

    # This module overrides CSV responses to allow large data downloads.
    # Could be expanded to JSON and XML in the future.
    #
    module Streaming

      def index
        super do |format|
          format.csv { stream_csv }
          format.xlsx { stream_xlsx }
          yield(format) if block_given?
        end
      end

      protected

      def stream_resource(&block)
        headers['X-Accel-Buffering'] = 'no'
        headers['Cache-Control'] = 'no-cache'
        self.response_body = Enumerator.new &block
      end

      def csv_filename
        "#{resource_collection_name.to_s.gsub('_', '-')}-#{Time.zone.now.to_date.to_s(:default)}.csv"
      end
      
      def xlsx_filename
        "#{resource_collection_name.to_s.gsub('_', '-')}-#{Time.zone.now.to_date.to_s(:default)}.xlsx"
      end

      def stream_csv
        headers['Content-Disposition'] = %{attachment; filename="#{csv_filename}"}
        stream_resource &active_admin_config.csv_builder.method(:build).to_proc.curry[self]
      end
      
      def stream_xlsx
        headers['Content-Disposition'] = %{attachment; filename="#{xlsx_filename}"}
      end

    end
  end
end
