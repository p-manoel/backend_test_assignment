class AddPerformanceIndexes < ActiveRecord::Migration[6.1]
  def change
    add_index :cars, [:brand_id, :price]
    add_index :cars, :price, where: 'price IS NOT NULL'
    add_index :brands, 'LOWER(name)'
  end
end
