(function() {

  (jQuery('document')).ready(function() {
    (jQuery('a.icon-minus')).live('click', function(event) {
      var list, listItem;
      event.preventDefault();
      listItem = (jQuery(this)).parent();
      list = (jQuery(listItem)).parent();
      listItem.animate({
        opacity: 0
      }, 200, 'linear', function() {
        var index;
        listItem.remove();
        index = 0;
        return ((list.find('li')).not('.template')).each(function(el) {
          ((jQuery(this)).find('input')).each(function(input) {
            return (jQuery(this)).attr('name', ((jQuery(this)).attr('name')).replace(/\[\d+\]/, "[" + index + "]"));
          });
          return index++;
        });
      });
      return false;
    });
    (jQuery('form.reference')).on('change', function() {
      return console.log('change!');
    });
    return (jQuery('input[name="title"]')).on('keyup', function() {
      var val;
      val = (jQuery(this)).val();
      return (jQuery('input[name="slug"]')).val(val.replace(/[^a-z0-9\-\.]/gi, '-'));
    });
  });

}).call(this);
