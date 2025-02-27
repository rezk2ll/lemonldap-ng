import { Dispatch, SetStateAction } from "react";
import "./CreationAssistant.css";
import "./IssuerAssistant.css";
export declare function IssuerAssistant({ visible, type, onIgnore, setVisible, }: {
    visible: boolean;
    type: string;
    onIgnore: Function;
    setVisible: Dispatch<SetStateAction<boolean>>;
}): import("react/jsx-runtime").JSX.Element;
