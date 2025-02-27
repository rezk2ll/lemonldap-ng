declare const rootReducer: import("redux").Reducer<import("redux").CombinedState<{
    config: import("../features/config/configSlice").ConfigState;
    router: import("redux-first-history").RouterState;
}>, import("redux").AnyAction>;
export declare const setupStore: (preloadedState?: Partial<RootState>) => import("@reduxjs/toolkit/dist/configureStore").ToolkitStore<import("redux").EmptyObject & {
    config: import("../features/config/configSlice").ConfigState;
    router: import("redux-first-history").RouterState;
}, import("redux").AnyAction, import("@reduxjs/toolkit").MiddlewareArray<[import("@reduxjs/toolkit").ThunkMiddleware<import("redux").CombinedState<{
    config: import("../features/config/configSlice").ConfigState;
    router: import("redux-first-history").RouterState;
}>, import("redux").AnyAction, undefined>, import("redux").Middleware<{}, any, import("redux").Dispatch<import("redux").AnyAction>>]>>;
export declare const store: import("@reduxjs/toolkit/dist/configureStore").ToolkitStore<import("redux").EmptyObject & {
    config: import("../features/config/configSlice").ConfigState;
    router: import("redux-first-history").RouterState;
}, import("redux").AnyAction, import("@reduxjs/toolkit").MiddlewareArray<[import("@reduxjs/toolkit").ThunkMiddleware<import("redux").CombinedState<{
    config: import("../features/config/configSlice").ConfigState;
    router: import("redux-first-history").RouterState;
}>, import("redux").AnyAction, undefined>, import("redux").Middleware<{}, any, import("redux").Dispatch<import("redux").AnyAction>>]>>;
export declare const history: import("history").History & {
    listenObject: boolean;
};
export type RootState = ReturnType<typeof rootReducer>;
export type AppStore = ReturnType<typeof setupStore>;
export type AppDispatch = AppStore["dispatch"];
export {};
