function getClonedTemplate(elementId) {
  var clone = $('#' + elementId).clone();
  clone.attr('id', '__template__');
  clone.addClass('template');

  replaceCloneIDs(clone, '__template__', elementId);
  return clone;
}

function replaceCloneIDs(clone, newDataID, originalDataID) {
  var changeUrlItems = clone.find('*[data-bip-url]');
  $.each( changeUrlItems, function( index, value ) {
    $(value).attr('data-bip-url', $(value).attr('data-bip-url').replace(originalDataID, newDataID));
  });

  var changeFormActionItems = clone.find('form[action]');
  $.each( changeFormActionItems, function( index, value ) {
    $(value).attr('action', $(value).attr('action').replace(originalDataID, newDataID));
    $(value).attr('id', newDataID + '_form_' + index);
  });
}

function cloneItem(template, newData, newDataId) {
  var clone = template.clone();
  clone.attr('id', newDataId);
  clone.removeClass('template');

  replaceCloneIDs(clone, newDataId, $(template).attr('id'));
  return clone;
}