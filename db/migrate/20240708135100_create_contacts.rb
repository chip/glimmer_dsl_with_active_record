require 'active_record'

class CreateContacts < ActiveRecord::Migration[7.1]
  def change
    create_table :contacts do |t|
      t.string     :first_name
      t.string     :last_name
      t.string     :email
      t.string     :phone
      t.string     :street
      t.string     :city
      t.string     :state_or_province
      t.string     :zip_or_postal_code
      t.string     :country
    end
  end
end
