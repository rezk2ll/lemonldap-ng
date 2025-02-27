import { ConfigState } from "../features/config/configSlice";
import "./SaveButton.css";
export declare function SavePopup({ config, openSavePopup, setOpenSavePopup, dispatch, partial, }: {
    config: ConfigState;
    openSavePopup: boolean;
    setOpenSavePopup: Function;
    dispatch: Function;
    partial?: boolean;
}): import("react/jsx-runtime").JSX.Element;
