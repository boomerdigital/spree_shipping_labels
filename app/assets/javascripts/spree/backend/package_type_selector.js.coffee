$ = jQuery

selector = 'select.package-type-selector'

$(document).on 'change', selector, ->
  $_ = $ @

  resource = $_.attr 'data-resource'
  package_type_id = $_.val()
  insurance = $_.attr 'data-insurance'

  $.post resource, package_type_id: package_type_id, insurance: insurance
    .fail ->
      $_.val $_.attr('data-last-value')
      alert 'Failed to generate label for selected package.'
    .done (label)->
      last_value = $_.attr 'data-last-value'
      $_.find("option[value='']").remove()
      $_.attr 'data-cost', label.cost
      $_.attr 'data-last-value', $_.val()
      $_.trigger 'label:changed'
      mesg = if last_value == ''
        'The label has been generated.'
      else
        'The label has been updated. You will need to void out the old label manually.'
      alert mesg

# Initialize each selector by storing it's current value so we can revert if
# changing a label fails.
$(document).ready ->
  for input in $ selector
    $_ = $ input
    $_.attr 'data-last-value', $_.val()
