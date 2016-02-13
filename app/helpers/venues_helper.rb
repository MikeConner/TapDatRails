module VenuesHelper
  def add_staff_member(venue, form_builder)
    # Precompute the html for a new content block by calling render on the same partial used for display
    # The index is just "NEW_RECORD", since it doesn't exist yet; it will be replaced later
    # Add a link with the text "Add License" and the id "add_license"
    # The inline Javascript takes the precomputed html block for a new license, replaces NEW_RECORD with a
    #  dynamically computed unique key, and inserts it in the DOM right before the link
    # Use #license elements as the unique key instead of "new Date().getTime()" so that I can predict it with RSpec
    #  
    form_builder.fields_for :staff_members, venue.staff_members.build, :child_index => 'NEW_RECORD' do |staff_member_form|
      html = render(:partial => 'staff_member', :locals => { :f => staff_member_form })
      onclick = "$('#{escape_javascript(html)}'.replace(/NEW_RECORD/g, $('.staff_member').length)).insertBefore('#add_staff_member'); return false;"
      
      content_tag(:a, 'Add Staff Member', :href => '#', :onclick => onclick, :id => 'add_staff_member')
    end
  end      
end