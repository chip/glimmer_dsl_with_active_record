require 'active_record'
require_relative './connection'
require_relative "./models"

Contact.create(first_name: 'Chip',
               last_name: 'Castle',
               email: 'chip@chipcastle.com',
               phone: '555-555-5555',
               street: 'Any street',
               city: 'Inlet Beach',
               state_or_province: 'FL',
               zip_or_postal_code: '55555',
               country: 'US')
