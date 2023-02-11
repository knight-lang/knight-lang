# Things that were added in later ruby versions to we can backport to earlier ones
class String
  method_defined?(:delete_prefix!) or def delete_prefix!(prefix)
    slice! /\A#{Regexp.escape(prefix)}/ and self
  end
end

class Hash
  method_defined?(:to_proc!) or def to_proc
    method(:[]).to_proc
  end
end
