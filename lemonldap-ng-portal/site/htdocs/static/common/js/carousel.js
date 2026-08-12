(function () {
  'use strict';

  function _toConsumableArray(arr) {
    return _arrayWithoutHoles(arr) || _iterableToArray(arr) || _unsupportedIterableToArray(arr) || _nonIterableSpread();
  }
  function _arrayWithoutHoles(arr) {
    if (Array.isArray(arr)) return _arrayLikeToArray(arr);
  }
  function _iterableToArray(iter) {
    if (typeof Symbol !== "undefined" && iter[Symbol.iterator] != null || iter["@@iterator"] != null) return Array.from(iter);
  }
  function _unsupportedIterableToArray(o, minLen) {
    if (!o) return;
    if (typeof o === "string") return _arrayLikeToArray(o, minLen);
    var n = Object.prototype.toString.call(o).slice(8, -1);
    if (n === "Object" && o.constructor) n = o.constructor.name;
    if (n === "Map" || n === "Set") return Array.from(o);
    if (n === "Arguments" || /^(?:Ui|I)nt(?:8|16|32)(?:Clamped)?Array$/.test(n)) return _arrayLikeToArray(o, minLen);
  }
  function _arrayLikeToArray(arr, len) {
    if (len == null || len > arr.length) len = arr.length;
    for (var i = 0, arr2 = new Array(len); i < len; i++) arr2[i] = arr[i];
    return arr2;
  }
  function _nonIterableSpread() {
    throw new TypeError("Invalid attempt to spread non-iterable instance.\nIn order to be iterable, non-array objects must have a [Symbol.iterator]() method.");
  }

  $(window).on("load", function () {
    var today = new Date().toISOString().split("T")[0];
    var publicNotifications = window.datas["publicNotifications"] ? window.datas["publicNotifications"] : {};

    // Most recent notifications first
    var byDateDesc = function byDateDesc(a, b) {
      if (a.date === b.date) return 0;
      return a.date < b.date ? 1 : -1;
    };
    var pendingNotifications = function pendingNotifications(type) {
      var notifications = publicNotifications[type] ? publicNotifications[type] : [];
      return notifications.filter(function (notif) {
        return notif.date <= today;
      }).sort(byDateDesc);
    };
    var ordonned_notifications = [].concat(_toConsumableArray(pendingNotifications("public_errors")), _toConsumableArray(pendingNotifications("public_warns")), _toConsumableArray(pendingNotifications("public_infos")));

    // Notifications may all be scheduled in the future: nothing to display,
    // don't build an empty carousel
    if (!ordonned_notifications.length) {
      return;
    }

    // Adapt some class to fit Bootstrap theme
    $("div.carousel").addClass("slide");
    var carouselInner = $("<div class='carousel-inner rounded'></div>");
    var carouselIndicators = $("<div class=\"carousel-indicators\"></div>");
    ordonned_notifications.forEach(function (element, index) {
      var bslevel = "";
      var level = element.uid.split("-").pop();
      switch (level) {
        case "info":
          bslevel = "info";
          break;
        case "warn":
          bslevel = "warning";
          break;
        case "error":
          bslevel = "danger";
          break;
        default:
          bslevel = "primary";
      }
      var notificationElement = $("<div class='carousel-item notif-container alert alert-".concat(bslevel, "'></div>"));
      var notificationIndicator = $("<button type=\"button\" data-bs-target=\"#carousel\" data-bs-slide-to=\"".concat(index, "\" aria-label=\"Slide ").concat(index + 1, "\"></button>"));
      if (index === 0) {
        notificationElement.addClass("active");
        notificationIndicator.addClass("active");
        notificationIndicator.attr("aria-current", "true");
      }
      var notificationTitle = $("<h4 class='text-center'></h4>");
      notificationTitle.append(element === null || element === void 0 ? void 0 : element.title);
      notificationElement.append(notificationTitle);
      var notificationSubtitle = $("<i class='d-flex justify-content-center align-items-center'></i>");
      notificationSubtitle.append(element === null || element === void 0 ? void 0 : element.subtitle);
      notificationElement.append(notificationSubtitle);
      var notificationContent = $("<p class='d-flex justify-content-center align-items-center'></p>");
      notificationContent.text(element === null || element === void 0 ? void 0 : element.text);
      notificationElement.append(notificationContent);
      carouselInner.append(notificationElement);
      carouselIndicators.append(notificationIndicator);
    });
    // Append the carousel inner to the carousel container
    var previousButton = $("<button class=\"carousel-control-prev\" type=\"button\" data-bs-target=\"#carousel\" data-bs-slide=\"prev\">\n        <span class=\"carousel-control-prev-icon\" aria-hidden=\"true\"></span>\n        <span class=\"visually-hidden\">Previous</span>\n      </button>");
    var nextButton = $("<button class=\"carousel-control-next\" type=\"button\" data-bs-target=\"#carousel\" data-bs-slide=\"next\">\n    <span class=\"carousel-control-next-icon\" aria-hidden=\"true\"></span>\n    <span class=\"visually-hidden\">Next</span>\n  </button>");

    // Indicators, controls and automatic scroll are useless with a single
    // notification
    var multiple = ordonned_notifications.length > 1;
    if (multiple) {
      $("div.carousel").append(carouselIndicators, carouselInner, previousButton, nextButton);
    } else {
      $("div.carousel").append(carouselInner);
    }

    // Bootstrap 5 no longer auto-initializes carousels whose content is injected
    // after page load, so instantiate it explicitly.
    var carouselElement = document.getElementById("carousel");
    if (multiple && carouselElement && window.bootstrap && window.bootstrap.Carousel) {
      var carousel = window.bootstrap.Carousel.getOrCreateInstance(carouselElement, {
        ride: "carousel",
        interval: 5000,
        wrap: true
      });
      carousel.cycle();
    }
  });

})();
