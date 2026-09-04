import { t } from "i18next";
import { PieChart } from "@mui/x-charts";
import { llngConfig } from "../utils/types";

export function ConfStats({ config }: { config: llngConfig }) {
  const appNum =
    (config.locationRules ? Object.keys(config.locationRules).length : 0) +
    (config.samlSPMetaDataXML
      ? Object.keys(config.samlSPMetaDataXML).length
      : 0) +
    (config.oidcRPMetaDataOptions
      ? Object.keys(config.oidcRPMetaDataOptions).length
      : 0) +
    (config.casAppMetaDataOptions
      ? Object.keys(config.casAppMetaDataOptions).length
      : 0);
  return (
    <div
      style={{
        display: "flex",
        flexDirection: "column",
        alignItems: "center",
        gap: 16,
        width: "100%",
      }}
    >
      <strong
        style={{
          fontSize: "1.15rem",
          color: "#26262b",
          alignSelf: "stretch",
          paddingBottom: 12,
          borderBottom: "2px solid #f0f0f2",
        }}
      >
        {t("appNum")} ({appNum})
      </strong>
      <PieChart
        series={[
          {
            data: [
              {
                id: 1,
                label: `${t("saml")} (${
                  config.samlSPMetaDataXML
                    ? Object.keys(config.samlSPMetaDataXML).length
                    : 0
                })`,
                value: config.samlSPMetaDataXML
                  ? Object.keys(config.samlSPMetaDataXML).length
                  : 0,
                color: "#FFB300",
              },
              {
                id: 2,
                label: `${t("virtualHost")} (${
                  config.locationRules
                    ? Object.keys(config.locationRules).length
                    : 0
                })`,
                value: config.locationRules
                  ? Object.keys(config.locationRules).length
                  : 0,
                color: "#FB8C00",
              },
              {
                id: 3,
                label: `${t("oidc")} (${
                  config.oidcRPMetaDataOptions
                    ? Object.keys(config.oidcRPMetaDataOptions).length
                    : 0
                })`,
                value: config.oidcRPMetaDataOptions
                  ? Object.keys(config.oidcRPMetaDataOptions).length
                  : 0,
                color: "#F4511E",
              },
              {
                id: 4,
                label: `${t("cas")} (${
                  config.casAppMetaDataOptions
                    ? Object.keys(config.casAppMetaDataOptions).length
                    : 0
                })`,
                value: config.casAppMetaDataOptions
                  ? Object.keys(config.casAppMetaDataOptions).length
                  : 0,
                color: "#BF360C",
              },
            ].filter((el) => el.value !== 0),
            innerRadius: 55,
            paddingAngle: 2,
            cornerRadius: 4,
          },
        ]}
        height={280}
        width={320}
        margin={{ top: 10, bottom: 60, left: 10, right: 10 }}
        slotProps={{
          legend: {
            direction: "row",
            position: { horizontal: "middle", vertical: "bottom" },
            padding: 0,
            itemMarkWidth: 12,
            itemMarkHeight: 12,
          },
        }}
      />
    </div>
  );
}
