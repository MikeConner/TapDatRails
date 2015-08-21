module CurrenciesHelper
  TOP_N = 5
  
  def add_denomination(currency, form_builder)
    # Precompute the html for a new content block by calling render on the same partial used for display
    # The index is just "NEW_RECORD", since it doesn't exist yet; it will be replaced later
    # Add a link with the text "Add License" and the id "add_license"
    # The inline Javascript takes the precomputed html block for a new license, replaces NEW_RECORD with a
    #  dynamically computed unique key, and inserts it in the DOM right before the link
    # Use #license elements as the unique key instead of "new Date().getTime()" so that I can predict it with RSpec
    #  
    form_builder.fields_for :denominations, currency.denominations.build, :child_index => 'NEW_RECORD' do |denomination_form|
      html = render(:partial => 'denomination', :locals => { :f => denomination_form })
      onclick = "$('#{escape_javascript(html)}'.replace(/NEW_RECORD/g, $('.denomination').length)).insertBefore('#add_denomination'); return false;"
      
      content_tag(:a, 'Add Denomination', :href => '#', :onclick => onclick, :id => 'add_denomination')
    end
  end    

  def add_generator(currency, form_builder)
    form_builder.fields_for :single_code_generators, currency.single_code_generators.build, :child_index => 'NEW_RECORD' do |generator_form|
      html = render(:partial => 'generator', :locals => { :f => generator_form })
      onclick = "$('#{escape_javascript(html)}'.replace(/NEW_RECORD/g, $('.generator').length)).insertBefore('#add_generator'); return false;"
      
      content_tag(:a, 'Add Single Code Voucher', :href => '#', :onclick => onclick, :id => 'add_generator')
    end
  end  
end
