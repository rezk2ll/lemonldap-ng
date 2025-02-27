import { TypedUseSelectorHook } from "react-redux";
import type { RootState } from "./store";
export declare const useAppDispatch: () => import("redux-thunk").ThunkDispatch<import("redux").CombinedState<{
    config: import("../features/config/configSlice").ConfigState;
    router: import("redux-first-history").RouterState;
}>, undefined, import("redux").AnyAction> & import("redux").Dispatch<import("redux").AnyAction>;
export declare const useAppSelector: TypedUseSelectorHook<RootState>;
