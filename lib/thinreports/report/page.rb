# coding: utf-8

module Thinreports
  module Report

    class BlankPage
      # @return [Integer]
      attr_accessor :no

      # @param [Boolean] count (nil)
      def initialize(count = nil)
        @count = count.nil? ? true : count
      end

      # @return [Boolean]
      def count?
        @count
      end

      # @return [Boolean] (true)
      def blank?
        true
      end
    end

    class Page < BlankPage
      include Core::Shape::Manager::Target

      # @return [Thinreports::Report::Base]
      attr_reader :report

      # @return [Thinreports::Layout::Base]
      attr_reader :layout

      # @param [Thinreports::Report::Base] report
      # @param [Thinreports::Layout::Base] layout
      # @param [Hash] options ({})
      # @option options [Boolean] :count (true)
      def initialize(report, layout, options = {})
        super(options.key?(:count) ? options[:count] : true)

        @report    = report
        @layout    = layout
        @finalized = false

        initialize_manager(layout.format) do |f|
          Core::Shape::Interface(self, f)
        end
      end

      # @return [Boolean] (false)
      def blank?
        false
      end

      def copy
        new_page = self.class.new(report, layout, count: count?)

        manager.shapes.each do |id, shape|
          new_shape = shape.copy(new_page)
          new_page.manager.shapes[id] = new_shape

          if new_shape.internal.type_of?(:list)
            new_page.manager.lists[id] = new_shape
          end
        end
        new_page
      end

      # @param [Hash] options
      # @option options [:create, :copy] :at (:create)
      def finalize(options = {})
        at = options[:at] || :create

        # For list shapes.
        if at == :create
          manager.lists.values.each {|list| list.manager.finalize }
        end

        @finalized = true
      end

      def finalized?
        @finalized
      end
    end

  end
end