import AddOutlinedIcon from "@mui/icons-material/AddOutlined";
import { Button } from "@mui/material";
import { t } from "i18next";
import { useAppDispatch, useAppSelector } from "../app/hooks";
import { CatCard } from "../components/catAndAppComponents/CatCard";
import { newCategory } from "../features/config/configSlice";
import attributes from "../static/attributes.json";
import "./CatAndAppList.css";

export function CatAndAppList() {
  const dispatch = useAppDispatch();
  const applicationList =
    useAppSelector((state) => state.config.data.config.applicationList) || {};
  const portal = useAppSelector((state) => state.config.data.config.portal);
  const catList = Object.keys(applicationList)
    .filter((key) => typeof applicationList[key] === "object")
    .sort(
      (key1, key2) =>
        Number((applicationList[key1] as Record<string, number>).order) -
        Number((applicationList[key2] as Record<string, number>).order)
    );
  return (
    <div className="catAndApp">
      <div className="catAndAppTop">
        <strong className="title">{t("applicationList")}</strong>
        <Button
          className="addCatButton"
          variant="contained"
          disableElevation
          size="small"
          startIcon={<AddOutlinedIcon />}
          onClick={() => dispatch(newCategory())}
        >
          {t("menuCategory")}
        </Button>
      </div>
      <div className="catList">
        {catList.map((key, index) => (
          <CatCard
            key={key}
            catId={key}
            cardIndex={index}
            dataLength={catList.length}
            data={applicationList[key]}
            dispatch={dispatch}
            portal={portal || attributes.portal.default}
          />
        ))}

        <Button
          className="addCatTile"
          variant="outlined"
          startIcon={<AddOutlinedIcon />}
          onClick={() => dispatch(newCategory())}
        >
          {t("menuCategory")}
        </Button>
      </div>
    </div>
  );
}
