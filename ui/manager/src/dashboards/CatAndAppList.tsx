import AddOutlinedIcon from "@mui/icons-material/AddOutlined";
import { Button } from "@mui/material";
import { t } from "i18next";
import { useAppDispatch, useAppSelector } from "../app/hooks";
import HomeButton from "../components/HomeButton";
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
    <div>
      <div className="top">
        <HomeButton />
        <strong className="title">
          {t("applicationList")}
          <Button onClick={() => dispatch(newCategory())}>
            <AddOutlinedIcon fontSize="large" color="secondary" />
          </Button>
        </strong>
      </div>
      <div>
        {catList.map((key, index) => (
          <CatCard
            key={index}
            catId={key}
            cardIndex={index}
            dataLength={catList.length}
            data={applicationList[key]}
            dispatch={dispatch}
            portal={portal || attributes.portal.default}
          />
        ))}

        <Button onClick={() => dispatch(newCategory())}>
          <AddOutlinedIcon fontSize="large" color="secondary" />
        </Button>
      </div>
    </div>
  );
}
