require 'glimmer_dsl_with_active_record/model/contact'

class GlimmerDslWithActiveRecord
  module View
    class GlimmerDslWithActiveRecord
      include Glimmer::LibUI::Application
    
          
      ## Add options like the following to configure CustomWindow by outside consumers
      #
      # options :title, :background_color
      # option :width, default: 320
      # option :height, default: 240
  
      ## Use before_body block to pre-initialize variables to use in body and
      #  to setup application menu
      #
      before_body do
        @contact = Contact.first
        menu_bar
      end
  
      ## Use after_body block to setup observers for controls in body
      #
      # after_body do
      #
      # end
  
      ## Add control content inside custom window body
      ## Top-most control must be a window or another custom window
      #
      body {
        window {
          # Replace example content below with your own custom window content
          content_size 300, 240
          title 'Glimmer Dsl With Active Record'
          
          margined true
          vertical_box {
            form {
              stretchy false

              entry {
                label 'First name'
                text <=> [@contact, :first_name]
              }
              entry {
                label 'Last name'
                text <=> [@contact, :last_name]
              }
              entry {
                label 'Email'
                text <=> [@contact, :email]
              }
              entry {
                label 'Phone'
                text <=> [@contact, :phone]
              }
              entry {
                label 'Street address'
                text <=> [@contact, :street]
              }
              entry {
                label 'City'
                text <=> [@contact, :city]
              }
              entry {
                label 'State/Province'
                text <=> [@contact, :state_or_province]
              }
              entry {
                label 'Zip/Postal code'
                text <=> [@contact, :zip_or_postal_code]
              }
              entry {
                label 'Country'
                text <=> [@contact, :country]
              }
            }
          }
        }
      }
  
      def menu_bar
        menu('File') {
          menu_item('Preferences...') {
            on_clicked do
              display_preferences_dialog
            end
          }
          
          # Enables quitting with CMD+Q on Mac with Mac Quit menu item
          quit_menu_item if OS.mac?
        }
        menu('Help') {
          if OS.mac?
            about_menu_item {
              on_clicked do
                display_about_dialog
              end
            }
          end
          
          menu_item('About') {
            on_clicked do
              display_about_dialog
            end
          }
        }
      end
  
      def display_about_dialog
        message = "Glimmer Dsl With Active Record #{VERSION}\n\n#{LICENSE}"
        msg_box('About', message)
      end
      
      def display_preferences_dialog
        window {
          title 'Preferences'
          content_size 200, 100
          
          margined true
          
          vertical_box {
            padded true
            
            label('Greeting:') {
              stretchy false
            }
            
            radio_buttons {
              stretchy false
              
              items Model::Greeting::GREETINGS
              selected <=> [@greeting, :text_index]
            }
          }
        }.show
      end
    end
  end
end
