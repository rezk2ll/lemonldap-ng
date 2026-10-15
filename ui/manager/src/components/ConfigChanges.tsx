import { t } from "i18next";
import { attributes } from "../metadata";
import { ConfigChange } from "../utils/configDiff";
import "./ConfigChanges.css";

// Above this, the list is cut (a restored configuration changes everything)
const MAX_DISPLAYED = 300;

function isSecret(path: string[]) {
  return path.some(
    (key) => attributes[key as keyof typeof attributes]?.type === "password"
  );
}

function Value({
  value,
  secret,
  className,
}: {
  value: unknown;
  secret: boolean;
  className: string;
}) {
  if (secret) return <span className={className}>••••••</span>;
  const text =
    typeof value === "object" ? JSON.stringify(value, null, 2) : String(value);
  if (text.length > 80 || text.includes("\n")) {
    return (
      <details className={className}>
        <summary>{text.split("\n")[0].slice(0, 60)}…</summary>
        <pre>{text}</pre>
      </details>
    );
  }
  return <span className={className}>{text}</span>;
}

export function ConfigChanges({ changes }: { changes: ConfigChange[] }) {
  if (!changes.length) {
    return <p className="configChangesEmpty">{t("noChanges")}</p>;
  }
  return (
    <div className="configChanges">
      <strong>
        {t("pendingChanges")} ({changes.length})
      </strong>
      <ul>
        {changes.slice(0, MAX_DISPLAYED).map((change) => {
          const secret = isSecret(change.path);
          return (
            <li key={change.path.join("\u0000")} className={change.kind}>
              <code
                className="configChangePath"
                title={t(change.path[change.path.length - 1])}
              >
                {change.path.join(" › ")}
              </code>
              <span className="configChangeValues">
                {change.kind !== "added" && (
                  <Value
                    value={change.before}
                    secret={secret}
                    className="before"
                  />
                )}
                {change.kind === "changed" && (
                  <span className="arrow">→</span>
                )}
                {change.kind !== "removed" && (
                  <Value
                    value={change.after}
                    secret={secret}
                    className="after"
                  />
                )}
              </span>
            </li>
          );
        })}
      </ul>
      {changes.length > MAX_DISPLAYED && (
        <p className="configChangesMore">
          + {changes.length - MAX_DISPLAYED} {t("otherChanges")}
        </p>
      )}
    </div>
  );
}
