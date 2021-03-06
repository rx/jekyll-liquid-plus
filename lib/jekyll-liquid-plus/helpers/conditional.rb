module LiquidPlus
  class Conditional
    EXPRESSION = /(.+?)\s+(unless|if)\s+(.+)/i
    TERNARY = /(.*?)\(\s*(.+?)\s+\?\s+(.+?)\s+:\s+(.+?)\s*\)(.+)?/

    class << self
      def parse(markup, context)
        strip_expression(markup, context) if evaluate_expression markup, context
      end

      def strip_expression(markup, context = false)
        if markup =~ TERNARY
          # Pick winner from ternary statement
          result = evaluate_ternary($2, $3, $4, context)
          markup = "#{$1} #{result} #{$5}"
        end
        markup =~ EXPRESSION ? $1 : markup
      end

      def evaluate_ternary(expression, if_true, if_false, context)
        evaluate('if', expression, context) ? if_true : if_false
      end

      def evaluate_expression(markup, context)
        if markup =~ EXPRESSION
          evaluate($2, $3.gsub(/ \|\| /, ' or '), context)
        else
          true
        end
      end

      def evaluate(type, expression, context)
        tag = if type == 'if'
          Liquid::If.new('if', expression, ["true","{% endif %}"])
        elsif type == 'unless'
          Liquid::Unless.new('unless', expression, ["true","{% endunless %}"])
        end
        tag.render(context) != ''
      end
    end
  end
end

