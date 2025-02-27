import { llngConfig } from "../../utils/types";
export declare function getMetadataConfig(num?: number): Promise<Response>;
export declare function getConfig(num: number): Promise<Response>;
export declare function getPartialConfig(): Promise<Response>;
export declare function saveConfig(config: llngConfig): Promise<Response>;
export declare function savePartialConfig(config: llngConfig): Promise<Response>;
