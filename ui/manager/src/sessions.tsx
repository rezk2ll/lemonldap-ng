import { mountApp } from "./bootstrap";
import SessionsApp from "./SessionsApp";

mountApp(<SessionsApp htmlName={process.env.REACT_APP_HTMLNAME || ""} />);
