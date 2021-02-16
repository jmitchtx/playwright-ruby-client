module Playwright
  class PlaywrightApi
    # Wrap ChannelOwner.
    # Playwright::ChannelOwners::XXXXX will be wrapped as Playwright::XXXXX
    # Playwright::XXXXX is automatically generated by development/generate_api
    #
    # @param channel_owner [ChannelOwner]
    # @note Intended for internal use only.
    def self.from_channel_owner(channel_owner)
      ChannelOwnerWrapper.new(channel_owner).wrap
    end

    class ChannelOwnerWrapper
      def initialize(impl)
        impl_class_name = impl.class.name
        unless impl_class_name.include?("::ChannelOwners::")
          raise "#{impl_class_name} is not ChannelOwners"
        end

        @impl = impl
      end

      def wrap
        api_class = detect_class_for(@impl.class)
        if api_class
          api_class.new(@impl)
        else
          raise NotImplementedError.new("Playwright::#{expected_class_name_for(@impl.class)} is not implemented")
        end
      end

      private

      def expected_class_name_for(klass)
        klass.name.split("::ChannelOwners::").last
      end

      def superclass_exist?(klass)
        ![::Playwright::ChannelOwner, Object].include?(klass.superclass)
      end

      def detect_class_for(klass)
        class_name = expected_class_name_for(klass)
        if ::Playwright.const_defined?(class_name)
          ::Playwright.const_get(class_name)
        elsif superclass_exist?(klass)
          detect_class_for(klass.superclass)
        else
          nil
        end
      end
    end

    class ApiImplementationWrapper
      def initialize(impl)
        impl_class_name = impl.class.name
        unless impl_class_name.end_with?("Impl")
          raise "#{impl_class_name} is not Impl"
        end

        @impl = impl
      end

      def wrap
        api_class = detect_class_for(@impl.class)
        if api_class
          api_class.new(@impl)
        else
          raise NotImplementedError.new("Playwright::#{expected_class_name_for(@impl.class)} is not implemented")
        end
      end

      private

      def expected_class_name_for(klass)
        # KeyboardImpl -> Keyboard
        # MouseImpl -> Mouse
        klass.name[0...-4].split("::").last
      end

      def detect_class_for(klass)
        class_name = expected_class_name_for(klass)
        if ::Playwright.const_defined?(class_name)
          ::Playwright.const_get(class_name)
        else
          nil
        end
      end
    end

    # @param impl [Playwright::ChannelOwner|Playwright::ApiImplementation]
    def initialize(impl)
      @impl = impl
    end

    def ==(other)
      @impl.to_s == other.instance_variable_get(:'@impl').to_s
    end

    # @param block [Proc]
    private def wrap_block_call(block)
      return nil unless block.is_a?(Proc)

      -> (*args) {
        wrapped_args = args.map { |arg| wrap_impl(arg) }
        block.call(*wrapped_args)
      }
    end

    private def wrap_impl(object)
      case object
      when ChannelOwner
        ChannelOwnerWrapper.new(object).wrap
      when ApiImplementation
        ApiImplementationWrapper.new(object).wrap
      when Array
        object.map { |obj| wrap_impl(obj) }
      else
        object
      end
    end

    private def unwrap_impl(object)
      if object.is_a?(PlaywrightApi)
        object.instance_variable_get(:@impl)
      else
        object
      end
    end
  end
end
