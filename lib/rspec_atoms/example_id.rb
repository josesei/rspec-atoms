# frozen_string_literal: true

module RSpecAtoms
  module ExampleId
    SELECTOR_PATTERN = /\[[^\]]+\]\z/

    module_function

    def normalize(value)
      value.to_s.sub(/\A\.\//, "")
    end

    def file_path(value)
      normalize(value).sub(SELECTOR_PATTERN, "")
    end
  end
end
