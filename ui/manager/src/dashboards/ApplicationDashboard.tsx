import { useAppDispatch } from "../app/hooks";
import { NativeApp } from "../components/applicationsComponents/NativeApp";
import { AppCtree } from "../components/applicationsComponents/AppCtree";
import { setError } from "../features/config/configSlice";

export function ApplicationDashboard({
  name,
  type,
}: {
  name: string;
  type: string;
}) {
  const dispatch = useAppDispatch();
  try {
    switch (type) {
      case "native":
        return <NativeApp name={name} />;
      case "AppCas":
        return <AppCtree type="casAppMetaDataNode" name={name} />;
      case "SPsaml":
        return <AppCtree type="samlSPMetaDataNode" name={name} />;
      case "RPoidc":
        return <AppCtree type="oidcRPMetaDataNode" name={name} />;
      default:
        return <div>¯\_(ツ)_/¯</div>;
    }
  } catch (e) {
    if (e instanceof Error) {
      dispatch(setError(e.message));
    }
    return <div>e</div>;
  }
}
