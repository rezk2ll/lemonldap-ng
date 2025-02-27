import "./AppCard.css";
declare function AppCard({ info, type, issuer, rule, }: {
    info: {
        name: string;
        config: Record<string, boolean | number | string>;
        partial?: boolean;
    };
    type: string;
    issuer?: boolean | number;
    rule: boolean;
}): import("react/jsx-runtime").JSX.Element;
export default AppCard;
