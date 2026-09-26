(function () {
  'use strict';

  function _arrayLikeToArray(r, a) {
    (null == a || a > r.length) && (a = r.length);
    for (var e = 0, n = Array(a); e < a; e++) n[e] = r[e];
    return n;
  }
  function _arrayWithoutHoles(r) {
    if (Array.isArray(r)) return _arrayLikeToArray(r);
  }
  function _iterableToArray(r) {
    if ("undefined" != typeof Symbol && null != r[Symbol.iterator] || null != r["@@iterator"]) return Array.from(r);
  }
  function _nonIterableSpread() {
    throw new TypeError("Invalid attempt to spread non-iterable instance.\nIn order to be iterable, non-array objects must have a [Symbol.iterator]() method.");
  }
  function _toConsumableArray(r) {
    return _arrayWithoutHoles(r) || _iterableToArray(r) || _unsupportedIterableToArray(r) || _nonIterableSpread();
  }
  function _unsupportedIterableToArray(r, a) {
    if (r) {
      if ("string" == typeof r) return _arrayLikeToArray(r, a);
      var t = {}.toString.call(r).slice(8, -1);
      return "Object" === t && r.constructor && (t = r.constructor.name), "Map" === t || "Set" === t ? Array.from(r) : "Arguments" === t || /^(?:Ui|I)nt(?:8|16|32)(?:Clamped)?Array$/.test(t) ? _arrayLikeToArray(r, a) : void 0;
    }
  }

  $(document).on('checkpassword', function (event, context) {
    var evType, newpasswordVal, setResult;
    context.password;
    evType = context.evType;
    setResult = context.setResult;
    // if checkHIBP is enabled
    if ($('#ppolicy-checkhibp-feedback').length > 0) {
      newpasswordVal = $("#newpassword").val();
      if (newpasswordVal.length >= 5) {
        // don't check HIBP at each keyup, but only when input focuses out
        if (evType === "focusout") {
          setResult('ppolicy-checkhibp-feedback', "waiting");
          return $.ajax({
            dataType: "json",
            url: "".concat(scriptname, "checkhibp"),
            method: "POST",
            data: {
              "password": btoa(String.fromCharCode.apply(String, _toConsumableArray(new TextEncoder().encode(newpasswordVal))))
            },
            context: document.body,
            success: function success(data) {
              var code, msg;
              code = data.code;
              msg = data.message;
              if (code !== void 0) {
                if (parseInt(code) === 0) {
                  // password ok
                  return setResult('ppolicy-checkhibp-feedback', "good");
                } else if (parseInt(code) === 2) {
                  // password compromised
                  return setResult('ppolicy-checkhibp-feedback', "bad");
                } else {
                  // unexpected error
                  console.error('checkhibp: backend error: ', msg);
                  return setResult('ppolicy-checkhibp-feedback', "unknown");
                }
              }
            },
            error: function error(j, status, err) {
              var res;
              if (err) {
                console.error('checkhibp: frontend error: ', err);
              }
              if (j) {
                res = JSON.parse(j.responseText);
              }
              if (res && res.error) {
                console.error('checkhibp: returned error: ', res);
              }
            }
          });
        }
      } else {
        // Check not performed yet
        return setResult('ppolicy-checkhibp-feedback', "unknown");
      }
    }
  });

})();
