export declare const exportData: (data: "full" | "samlMetadata" | "oidcMetadata", num: number) => Promise<void>;
export declare const exportOidcMetadata: (confNum: number) => Promise<void>;
export declare const exportSamlMetadata: (confNum: number) => Promise<void>;
