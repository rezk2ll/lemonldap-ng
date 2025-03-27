import AddOutlinedIcon from "@mui/icons-material/AddOutlined";
import ArrowDownwardOutlinedIcon from "@mui/icons-material/ArrowDownwardOutlined";
import ArrowUpwardOutlinedIcon from "@mui/icons-material/ArrowUpwardOutlined";
import RemoveOutlinedIcon from "@mui/icons-material/RemoveOutlined";
import {
  Button,
  Card,
  CardContent,
  CardHeader,
  IconButton,
  TextField,
} from "@mui/material";
import {
  delCategory,
  moveCat,
  newApplication,
  renameCategory,
} from "../../features/config/configSlice";
import { MenuAppCard } from "./MenuAppCard";

export function CatCard({
  catId,
  cardIndex,
  dataLength,
  data,
  dispatch,
  portal,
}: {
  catId: string;
  cardIndex: number;
  dataLength: number;
  data: Record<
    string,
    string | number | Record<string, string | number | Record<string, string>>
  >;
  dispatch: Function;
  portal: string;
}) {
  const applications = Object.keys(data)
    .filter((key) => typeof data[key] === "object")
    .sort(
      (key1, key2) =>
        Number((data[key1] as Record<string, number>).order) -
        Number((data[key2] as Record<string, number>).order)
    );
  return (
    <Card className="catCard">
      <CardHeader
        className="catHeader"
        title={
          <>
            <TextField
              size="small"
              value={data.catname}
              onChange={(e) =>
                dispatch(renameCategory({ id: catId, newname: e.target.value }))
              }
            />
            <>
              <IconButton
                onClick={() =>
                  dispatch(moveCat({ category: catId, direction: "up" }))
                }
                disabled={cardIndex === 0}
              >
                <ArrowUpwardOutlinedIcon />
              </IconButton>
              <IconButton
                onClick={() =>
                  dispatch(
                    moveCat({
                      category: catId,
                      direction: "down",
                    })
                  )
                }
                disabled={cardIndex === dataLength - 1}
              >
                <ArrowDownwardOutlinedIcon />
              </IconButton>
              <IconButton onClick={() => dispatch(delCategory(catId))}>
                <RemoveOutlinedIcon />
              </IconButton>
            </>
          </>
        }
      />
      <CardContent className="applications">
        {applications.map((key, index) => {
          if (typeof data[key] === "object") {
            const app = data[key] as Record<string, Record<string, string>>;
            return (
              <MenuAppCard
                key={index}
                app={app}
                cardIndex={cardIndex}
                catId={catId}
                portal={portal}
                appKey={key}
                appIndex={index}
                applications={applications}
                dispatch={dispatch}
              />
            );
          }
          return null;
        })}
        <Button onClick={() => dispatch(newApplication(catId))}>
          <AddOutlinedIcon color="secondary" />
        </Button>
      </CardContent>
    </Card>
  );
}
