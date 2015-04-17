$(function () {
  var click_callback = function () {
    var $this = $(this),
        $td = $this.parent().parent().find('td:first-child'),
        $input = $td.find('input').first(),
        $new_input = $('<input>').attr('name', $input.attr('name').replace('old_path', '_destroy')).attr('value', 'true');
    $td.append($new_input).parent().hide();
  };
  $('.delete-button').on('click', click_callback);


  $('.add-button').on('click', function () {
    var $this = $(this),
        $button_row = $this.parent().parent(),
        $table = $button_row.parent(),
        new_index = $table.find('tr').length - 3; // 3 because of header
    $('<tr>')
        .append($('<td><input name="files[' + new_index + '][old_path]" type="hidden" value=""><input name="files[' + new_index + '][length]" value=""></td>'))
        .append($('<td><input name="files[' + new_index + '][md5sum]" size="32" value=""></td>'))
        .append($('<td><input name="files[' + new_index + '][path]" size="128" value=""></td>'))
        .append($('<td align="center">').append($('<input type="button" value="-" class="delete-button">').on('click', click_callback))).insertBefore($button_row)
  });
});