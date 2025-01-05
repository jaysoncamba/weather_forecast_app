class CreateLocationForecasts < ActiveRecord::Migration[8.0]
  def change
    create_table :location_forecasts do |t|
      t.string :location_name
      t.float :latitude
      t.float :longitude
      t.json :forecast

      t.timestamps
    end
  end
end
