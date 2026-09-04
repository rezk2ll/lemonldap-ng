import { mountApp } from "./bootstrap";
import TwofaApp from "./TwofaApp";

mountApp(<TwofaApp htmlName={process.env.REACT_APP_HTMLNAME || ""} />);
