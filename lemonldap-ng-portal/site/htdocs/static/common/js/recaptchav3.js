(function() {
  $(document).ready(function() {
    $('#loginfm').on('submit', function(e) {
      e.preventDefault();
      grecaptcha.ready(function() {
        grecaptcha.execute(datas['datasitekey'], {action: 'submit'}).then(function(token) {
          $('#grr').val(token);
          console.log('V', $('#grr').val);
          $('#loginfm').unbind('submit').submit();
        });
    })
   })
  });
}).call(this);
