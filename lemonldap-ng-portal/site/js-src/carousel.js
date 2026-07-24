$(window).on("load", function() {
  // Adapt some class to fit Bootstrap theme
  $("div.carousel").addClass("slide");
  const today = new Date().toISOString().split("T")[0];

  const publicNotifications = window.datas["publicNotifications"] ?
    window.datas["publicNotifications"] : {};
  const public_errors = publicNotifications["public_errors"]
    .filter((notif) => notif.date <= today)
    .sort((a, b) => a.date < b.date);
  const public_warns = publicNotifications["public_warns"]
    .filter((notif) => notif.date <= today)
    .sort((a, b) => a.date < b.date);
  const public_infos = publicNotifications["public_infos"]
    .filter((notif) => notif.date <= today)
    .sort((a, b) => a.date < b.date);
  const ordonned_notifications = [
    ...public_errors,
    ...public_warns,
    ...public_infos,
  ];


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

  $("div.carousel").append(
    carouselIndicators,
    carouselInner,
    previousButton,
    nextButton
  );

  // Bootstrap 5 no longer auto-initializes carousels whose content is injected
  // after page load, so instantiate it explicitly.
  const carouselElement = document.getElementById("carousel");
  if (carouselElement && window.bootstrap && window.bootstrap.Carousel) {
    window.bootstrap.Carousel.getOrCreateInstance(carouselElement);
  }
});