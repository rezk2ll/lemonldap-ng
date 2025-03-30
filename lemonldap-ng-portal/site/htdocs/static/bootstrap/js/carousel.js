$(window).on("load", function () {
  // Adapt some class to fit Bootstrap theme
  $("div.carousel").addClass("slide");
  const today = new Date().toISOString().split("T")[0];

  const publicNotifications = window.datas["publicNotifications"]
    ? window.datas["publicNotifications"]
    : {};
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

  const carouselInner = $("<div class='carousel-inner'></div>");
  const carouselIndicators = $(`<ol class="carousel-indicators"></ol>`);
  ordonned_notifications.forEach((element, index) => {
    const notificationElement = $(
      `<div class='carousel-item  notif-container ${element.uid}'></div>`
    );

    const notificationIndicator = $(
      `<li data-target="#carousel" data-slide-to="${index}"></li>`
    );

    if (index === 0) {
      notificationElement.addClass("active");
      notificationIndicator.addClass("active");
    }

    const notificationTitle = $("<h4 class='text-center'></h4>");
    const infoIcon =
      $(` <svg xmlns="http://www.w3.org/2000/svg" width="25" height="25" fill="blue" class="bi m-2 bi-info-circle-fill " viewBox="0 0 16 16">
      <path d="M8 16A8 8 0 1 0 8 0a8 8 0 0 0 0 16m.93-9.412-1 4.705c-.07.34.029.533.304.533.194 0 .487-.07.686-.246l-.088.416c-.287.346-.92.598-1.465.598-.703 0-1.002-.422-.808-1.319l.738-3.468c.064-.293.006-.399-.287-.47l-.451-.081.082-.381 2.29-.287zM8 5.5a1 1 0 1 1 0-2 1 1 0 0 1 0 2"/>
    </svg>`);
    notificationTitle.append(infoIcon);
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
    $(`<a class="carousel-control-prev" href="#carousel" role="button" data-slide="prev">
        <span class="carousel-control-prev-icon" aria-hidden="true"></span>
        <span class="sr-only">Previous</span>
      </a>`);
  const nextButton =
    $(`<a class="carousel-control-next" href="#carousel" role="button" data-slide="next">
    <span class="carousel-control-next-icon" aria-hidden="true"></span>
    <span class="sr-only">Next</span>
  </a>`);

  $("div.carousel").append(
    carouselIndicators,
    carouselInner,
    previousButton,
    nextButton
  );
});
