import { mountApp } from "./bootstrap";
import NotificationsApp from "./NotificationsApp";

mountApp(<NotificationsApp htmlName={process.env.REACT_APP_HTMLNAME || ""} />);
