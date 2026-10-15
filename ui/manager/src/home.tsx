import { mountApp } from "./bootstrap";
import HomeApp from "./HomeApp";

mountApp(<HomeApp htmlName={process.env.REACT_APP_HTMLNAME || ""} />);
