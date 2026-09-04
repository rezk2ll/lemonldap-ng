import {
  combineReducers,
  configureStore,
  type Middleware,
} from "@reduxjs/toolkit";
import configReducer from "../features/config/configSlice";
import { createReduxHistoryContext } from "redux-first-history";
import { createBrowserHistory, createMemoryHistory } from "history";

const isTest = typeof process !== "undefined" && process.env.NODE_ENV === "test";
const historyInstance = isTest ? createMemoryHistory() : createBrowserHistory();

const { createReduxHistory, routerMiddleware, routerReducer } =
  createReduxHistoryContext({ history: historyInstance });

const rootReducer = combineReducers({
  config: configReducer,
  router: routerReducer,
});

export const setupStore = (preloadedState?: Partial<RootState>) => {
  return configureStore({
    reducer: rootReducer,
    preloadedState,
    middleware: (getDefaultMiddleware) =>
      getDefaultMiddleware().concat(routerMiddleware as Middleware),
  });
};

export const store = setupStore();

export const history = createReduxHistory(store);

export type RootState = ReturnType<typeof rootReducer>;
export type AppStore = ReturnType<typeof setupStore>;
export type AppDispatch = AppStore["dispatch"];
