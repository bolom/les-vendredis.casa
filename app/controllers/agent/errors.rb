# frozen_string_literal: true

module Agent
  module Errors
    class UnauthorizedError < StandardError; end

    class ForbiddenError < StandardError
      attr_reader :permission

      def initialize(permission)
        @permission = permission
        super("missing permission: #{permission}")
      end
    end

    class NotFoundError < StandardError; end

    class UnprocessableError < StandardError; end
  end
end
