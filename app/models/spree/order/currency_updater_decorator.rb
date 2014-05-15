module Spree
  class Order < Spree::Base
    CurrencyUpdater.class_eval do

      # Returns the price object from given item
      def list_price_from_line_item(line_item)
        role_ids = line_item.order.user.present? ? line_item.order.user.roles.pluck(:id) : nil
        line_item.variant.list_price_in(price.currency, line_item.order.store.id, role_ids)
      end

      # Returns the price object from given item
      def price_from_line_item(line_item)
        role_ids = line_item.order.user.present? ? line_item.order.user.roles.pluck(:id) : nil
        line_item.variant.price_in(price.currency, line_item.order.store.id, role_ids)
      end

      # Updates price from given line item
      def update_line_item_price!(line_item)
        list_price = list_price_from_line_item(line_item)
        price = price_from_line_item(line_item)

        if price
          line_item.update_attributes!(
            currency: price.currency,
            list_price: list_price.price,
            price: price.price
          )
        else
          raise RuntimeError, "no #{currency} price found for #{line_item.product.name} (#{line_item.variant.sku})"
        end
      end

    end
  end
end
