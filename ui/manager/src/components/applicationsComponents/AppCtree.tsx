import ExpandLess from "@mui/icons-material/ExpandLess";
import ExpandMore from "@mui/icons-material/ExpandMore";
import { Box, CircularProgress, Collapse, Divider, List } from "@mui/material";
import { t } from "i18next";
import { useEffect, useState } from "react";
import { useAppDispatch, useAppSelector } from "../../app/hooks";
import { updateAppParam } from "../../features/config/configSlice";
import BoolForm from "../../forms/BoolForm";
import BoolOrExprForm from "../../forms/BoolOrExprForm";
import FileForm from "../../forms/FileForm";
import IntForm from "../../forms/IntForm";
import IntOrNullForm from "../../forms/IntOrNullForm";
import KeyTextContainerForm from "../../forms/KeyTextContainerForm";
import LongtextForm from "../../forms/LongtextForm";
import OidcAttributeContainerForm from "../../forms/OidcAttributeContainerForm";
import PasswordForm from "../../forms/PasswordForm";
import SelectForm from "../../forms/SelectForm";
import TextForm from "../../forms/TextForm";
import TroolForm from "../../forms/TroolForm";
import UrlForm from "../../forms/UrlForm";
import { attributes } from "../../metadata";
import { CtreeNode, children, findCtree, isGroup, loadStruct } from "../../utils/ctrees";
import HomeButton from "../HomeButton";
import "./AppPage.css";

// Groups listed in the side menu: those of a plain container. The groups of a
// "simpleInputContainer" (e.g. mTLS inside security) are shown inline.
function navGroups(node: CtreeNode): CtreeNode[] {
  return node.type === "simpleInputContainer" ? [] : children(node).filter(isGroup);
}

function findByPath(nodes: CtreeNode[], path: string[]): CtreeNode | undefined {
  let node: CtreeNode | undefined;
  let level = nodes;
  for (const title of path) {
    node = level.find((n) => n.title === title);
    if (!node) return undefined;
    level = children(node);
  }
  return node;
}

// One parameter of the application: leaves are stored in
// config[<type>Options][name][param], hashes (macros, claims...) in
// config[param][name].
function AppField({ node, name, optionsKey }: { node: CtreeNode; name: string; optionsKey: string }) {
  const config = useAppSelector((state) => state.config.data.config) as unknown as Record<
    string,
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    Record<string, any> | undefined
  >;
  const dispatch = useAppDispatch();
  const title = node.title;
  const type = node.type || attributes[title]?.type || "text";

  if (typeof node.cnodes === "string") {
    const value = config[title]?.[name] || {};
    switch (type) {
      case "oidcAttributeContainer":
        return <OidcAttributeContainerForm value={value} fieldName={title} appName={name} />;
      case "keyTextContainer":
        return (
          <tr>
            <KeyTextContainerForm
              value={value}
              fieldName={title}
              updateFunc={(v: Record<string, string>) => dispatch(updateAppParam({ key: title, name, value: v }))}
            />
          </tr>
        );
      default:
        return null;
    }
  }

  const value = config[optionsKey]?.[name]?.[title];
  const update = (v: unknown) => dispatch(updateAppParam({ key: optionsKey, name, option: title, value: v }));
  const updateInt = (v: string) => update(v === "" ? "" : Number(v));
  const props = { fieldName: title, updateFunc: update };
  let field;
  switch (type) {
    case "bool":
      field = <BoolForm {...props} value={Number(value)} />;
      break;
    case "trool":
      field = <TroolForm {...props} value={Number(value)} />;
      break;
    case "boolOrExpr":
      field = <BoolOrExprForm {...props} value={value} />;
      break;
    case "select":
      field = <SelectForm {...props} value={value ?? ""} />;
      break;
    case "int":
      field = <IntForm {...props} updateFunc={updateInt} value={Number(value)} />;
      break;
    case "intOrNull":
      field = <IntOrNullForm {...props} updateFunc={updateInt} value={value} />;
      break;
    case "password":
      field = <PasswordForm {...props} value={value} />;
      break;
    case "longtext":
      field = <LongtextForm {...props} value={value} />;
      break;
    case "url":
      field = <UrlForm {...props} value={value} />;
      break;
    case "file":
      field = <FileForm {...props} value={value} />;
      break;
    default:
      field = <TextForm {...props} value={value} />;
  }
  return <tr>{field}</tr>;
}

// Parameters of a section; inline groups get a sub-heading.
function SectionFields({ node, name, optionsKey }: { node: CtreeNode; name: string; optionsKey: string }) {
  if (!isGroup(node)) {
    return <AppField node={node} name={name} optionsKey={optionsKey} />;
  }
  const inNav = new Set(navGroups(node));
  return (
    <>
      {children(node)
        .filter((child) => !inNav.has(child))
        .map((child) =>
          isGroup(child) ? (
            <SectionGroup key={child.title} node={child} name={name} optionsKey={optionsKey} />
          ) : (
            <AppField key={child.title} node={child} name={name} optionsKey={optionsKey} />
          ),
        )}
    </>
  );
}

function SectionGroup(props: { node: CtreeNode; name: string; optionsKey: string }) {
  return (
    <>
      <tr className="subsection">
        <th colSpan={2}>{t(props.node.title)}</th>
      </tr>
      <SectionFields {...props} />
    </>
  );
}

function NavItem({
  node,
  path,
  selected,
  select,
  depth,
}: {
  node: CtreeNode;
  path: string[];
  selected: string[];
  select: (path: string[]) => void;
  depth: number;
}) {
  const groups = navGroups(node);
  const key = path.join("/");
  const isSelected = selected.join("/") === key;
  const isOpen = selected.slice(0, path.length).join("/") === key;
  return (
    <>
      <label
        className={`${depth ? "suboption" : "option"} ${isSelected ? "selected" : ""}`}
        data-testid={node.title}
        onClick={() => select(path)}
      >
        {groups.length > 0 && <div>{isOpen ? <ExpandLess /> : <ExpandMore />}</div>}
        <span>{t(node.title)}</span>
      </label>
      {groups.length > 0 && (
        <Collapse in={isOpen} timeout="auto" unmountOnExit>
          <List className="optionNavbar sub">
            {groups.map((group) => (
              <NavItem key={group.title} node={group} path={[...path, group.title]} selected={selected} select={select} depth={depth + 1} />
            ))}
          </List>
        </Collapse>
      )}
    </>
  );
}

// Page of a configured object (OIDC RP...), generated from its ctree in
// nstruct.json: one menu entry per top-level node, sub-entries for groups.
export function AppCtree({ type, name }: { type: string; name: string }) {
  const [ctree, setCtree] = useState<CtreeNode[] | undefined>();
  const [selected, setSelected] = useState<string[]>([]);
  const optionsKey = type.replace(/Node$/, "Options");

  useEffect(() => {
    let active = true;
    loadStruct()
      .then((struct) => findCtree(struct, type) || [])
      .catch(() => [])
      .then((nodes) => {
        if (!active) return;
        setCtree(nodes);
        setSelected((cur) => (cur.length || !nodes.length ? cur : [nodes[0].title]));
      });
    return () => {
      active = false;
    };
  }, [type]);

  if (!ctree) {
    return (
      <Box sx={{ display: "flex" }}>
        <CircularProgress />
      </Box>
    );
  }
  const section = findByPath(ctree, selected);
  return (
    <div>
      <div className="top">
        <HomeButton />
        <strong className="title">{name}</strong>
      </div>
      <div className="app">
        <List className="optionNavbar" component="nav">
          {ctree.map((node) => (
            <NavItem key={node.title} node={node} path={[node.title]} selected={selected} select={setSelected} depth={0} />
          ))}
        </List>
        <Divider className="divider" orientation="vertical" variant="middle" />
        <div className="appDesc">
          {section && (
            <div className="box">
              {isGroup(section) && <strong className="title">{t(section.title)}</strong>}
              <table>
                <tbody>
                  <SectionFields node={section} name={name} optionsKey={optionsKey} />
                </tbody>
              </table>
            </div>
          )}
        </div>
      </div>
    </div>
  );
}
