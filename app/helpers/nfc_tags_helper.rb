module NfcTagsHelper
  def add_payload(tag, form_builder)
    # Precompute the html for a new content block by calling render on the same partial used for display
    # The index is just "NEW_RECORD", since it doesn't exist yet; it will be replaced later
    # Add a link with the text "Add License" and the id "add_license"
    # The inline Javascript takes the precomputed html block for a new license, replaces NEW_RECORD with a
    #  dynamically computed unique key, and inserts it in the DOM right before the link
    # Use #license elements as the unique key instead of "new Date().getTime()" so that I can predict it with RSpec
    #  
    form_builder.fields_for :payloads, tag.payloads.build(:threshold => 1), :child_index => 'NEW_RECORD' do |payload_form|
      html = render(:partial => 'payload', :locals => { :f => payload_form })
      onclick = "$('#{escape_javascript(html)}'.replace(/NEW_RECORD/g, $('.payload').length)).insertBefore('#add_payload'); return false;"
      
      content_tag(:a, 'Add Yapa', :href => '#', :onclick => onclick, :id => 'add_payload')
    end
  end    
end
