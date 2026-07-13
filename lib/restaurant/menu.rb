# frozen_string_literal: true

module Restaurant
  MenuItem = Struct.new(:name, :price, :stock, keyword_init: true)

  # fake DB. lookup by name.
  module Menu
    ITEMS = {
      # Pizzas
      "Margherita Pizza"  => MenuItem.new(name: "Margherita Pizza",  price: 12.0, stock: 5),
      "Pepperoni Pizza"   => MenuItem.new(name: "Pepperoni Pizza",   price: 14.0, stock: 4),
      "Four Cheese Pizza" => MenuItem.new(name: "Four Cheese Pizza", price: 15.0, stock: 3),

      # Pastas
      "Spaghetti Carbonara" => MenuItem.new(name: "Spaghetti Carbonara", price: 13.5, stock: 6),
      "Lasagna"             => MenuItem.new(name: "Lasagna",             price: 14.5, stock: 2),
      "Penne Arrabbiata"    => MenuItem.new(name: "Penne Arrabbiata",    price: 11.5, stock: 7),

      # Burgers
      "Classic Burger" => MenuItem.new(name: "Classic Burger", price: 10.0, stock: 8),
      "Cheeseburger"   => MenuItem.new(name: "Cheeseburger",   price: 11.0, stock: 8),
      "Veggie Burger"  => MenuItem.new(name: "Veggie Burger",  price: 10.5, stock: 0),

      # Salads
      "Caesar Salad" => MenuItem.new(name: "Caesar Salad", price: 8.5, stock: 9),
      "Greek Salad"  => MenuItem.new(name: "Greek Salad",  price: 8.0, stock: 5),

      # Sides
      "French Fries" => MenuItem.new(name: "French Fries", price: 4.0, stock: 20),
      "Garlic Bread" => MenuItem.new(name: "Garlic Bread", price: 4.5, stock: 12),
      "Onion Rings"  => MenuItem.new(name: "Onion Rings",  price: 5.0, stock: 6),

      # Drinks
      "Coke"            => MenuItem.new(name: "Coke",            price: 3.0, stock: 10),
      "Sparkling Water" => MenuItem.new(name: "Sparkling Water", price: 2.5, stock: 15),
      "Orange Juice"    => MenuItem.new(name: "Orange Juice",    price: 3.5, stock: 8),
      "Espresso"        => MenuItem.new(name: "Espresso",        price: 2.0, stock: 30),

      # Desserts
      "Tiramisu"       => MenuItem.new(name: "Tiramisu",       price: 6.5, stock: 0),
      "Cheesecake"     => MenuItem.new(name: "Cheesecake",     price: 6.0, stock: 4),
      "Chocolate Cake" => MenuItem.new(name: "Chocolate Cake", price: 6.5, stock: 5),
      "Gelato"         => MenuItem.new(name: "Gelato",         price: 5.5, stock: 7)
    }.freeze

    def self.find(name) = ITEMS[name]   # nil if not on menu
  end
end
