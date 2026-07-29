$(window).on("load", function() {
  const today = new Date().toISOString().split("T")[0];

  const publicNotifications = window.datas["publicNotifications"] ?
    window.datas["publicNotifications"] : {};

  // Most recent notifications first
  const byDateDesc = function(a, b) {
    if (a.date === b.date) return 0;
    return a.date < b.date ? 1 : -1;
  };
  const pendingNotifications = function(type) {
    const notifications = publicNotifications[type] ?
      publicNotifications[type] : [];
    return notifications
      .filter((notif) => notif.date <= today)
      .sort(byDateDesc);
  };
  const ordonned_notifications = [
    ...pendingNotifications("public_errors"),
    ...pendingNotifications("public_warns"),
    ...pendingNotifications("public_infos"),
  ];

  // Notifications may all be scheduled in the future: nothing to display,
  // don't build an empty carousel
  if (!ordonned_notifications.length) {
    return;
  }

  // Adapt some class to fit Bootstrap theme
  $("div.carousel").addClass("slide");

  const carouselInner = $("<div class='carousel-inner rounded'></div>");
  const carouselIndicators = $(`<div class="carousel-indicators"></div>`);
  ordonned_notifications.forEach((element, index) => {
    var bslevel = "";
    const level = element.uid.split("-").pop();
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

    const notificationElement = $(
      `<div class='carousel-item notif-container alert alert-${bslevel}'></div>`
    );

    const notificationIndicator = $(
      `<button type="button" data-bs-target="#carousel" data-bs-slide-to="${index}" aria-label="Slide ${index + 1}"></button>`
    );

    if (index === 0) {
      notificationElement.addClass("active");
      notificationIndicator.addClass("active");
      notificationIndicator.attr("aria-current", "true");
    }

    const notificationTitle = $("<h4 class='text-center'></h4>");
    notificationTitle.append(element?.title);
    notificationElement.append(notificationTitle);
    const notificationSubtitle = $(
      "<i class='d-flex justify-content-center align-items-center'></i>"
    );
    notificationSubtitle.append(element?.subtitle);
    notificationElement.append(notificationSubtitle);
    const notificationContent = $(
      "<p class='d-flex justify-content-center align-items-center'></p>"
    );
    notificationContent.text(element?.text);
    notificationElement.append(notificationContent);
    carouselInner.append(notificationElement);
    carouselIndicators.append(notificationIndicator);
  });
  // Append the carousel inner to the carousel container
  const previousButton =
    $(`<button class="carousel-control-prev" type="button" data-bs-target="#carousel" data-bs-slide="prev">
        <span class="carousel-control-prev-icon" aria-hidden="true"></span>
        <span class="visually-hidden">Previous</span>
      </button>`);
  const nextButton =
    $(`<button class="carousel-control-next" type="button" data-bs-target="#carousel" data-bs-slide="next">
    <span class="carousel-control-next-icon" aria-hidden="true"></span>
    <span class="visually-hidden">Next</span>
  </button>`);

  // Indicators, controls and automatic scroll are useless with a single
  // notification
  const multiple = ordonned_notifications.length > 1;
  if (multiple) {
    $("div.carousel").append(
      carouselIndicators,
      carouselInner,
      previousButton,
      nextButton
    );
  } else {
    $("div.carousel").append(carouselInner);
  }

  // Bootstrap 5 no longer auto-initializes carousels whose content is injected
  // after page load, so instantiate it explicitly.
  const carouselElement = document.getElementById("carousel");
  if (multiple && carouselElement && window.bootstrap && window.bootstrap.Carousel) {
    const carousel = window.bootstrap.Carousel.getOrCreateInstance(
      carouselElement, {
        ride: "carousel",
        interval: 5000,
        wrap: true,
      }
    );
    carousel.cycle();
  }
});
