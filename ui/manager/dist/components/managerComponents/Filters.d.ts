import "./Filters.css";
declare function FilterToggle({ filters, setFilters, }: {
    filters: {
        alpha: boolean;
        search: string;
    };
    setFilters: Function;
}): import("react/jsx-runtime").JSX.Element;
export default FilterToggle;
