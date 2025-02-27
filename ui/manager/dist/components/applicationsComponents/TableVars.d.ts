export declare function TableVars({ appName, vars, tableID, dispatch, delFunction, updateFunction, }: {
    appName: string;
    vars: Record<string, string>;
    tableID: string;
    dispatch: Function;
    delFunction: Function;
    updateFunction: Function;
}): import("react/jsx-runtime").JSX.Element;
export declare function updateHeaders(tableID: string): Record<string, string>;
