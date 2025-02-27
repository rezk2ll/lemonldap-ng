import { NodeApi } from "react-arborist";
import { treeFormat } from "../utils/recursTree";
export default function VirtualHostContainerForm({ node, dispatch, }: {
    node: NodeApi<treeFormat>;
    dispatch: Function;
}): import("react/jsx-runtime").JSX.Element;
