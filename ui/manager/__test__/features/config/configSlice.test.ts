import reducer, {
  changeApplicationField,
  changeCategoryTranslation,
  ConfigState,
  initialState,
} from "../../../src/features/config/configSlice";
import { llngConfig } from "../../../src/utils/types";

const state = (): ConfigState => ({
  ...initialState,
  data: {
    ...initialState.data,
    config: {
      applicationList: {
        "1cat": {
          catname: "Category",
          type: "category",
          order: 1,
          app1: { type: "application", order: 1, options: { name: "App 1" } },
        },
      },
    } as unknown as llngConfig,
  },
});

const category = (s: ConfigState) =>
  s.data.config.applicationList?.["1cat"] as Record<string, any>;

describe("menu translation keys", () => {
  it("sets and removes the translation key of a category", () => {
    let s = reducer(
      state(),
      changeCategoryTranslation({ id: "1cat", value: "myCategory" })
    );
    expect(category(s).options).toEqual({ translation: "myCategory" });
    s = reducer(s, changeCategoryTranslation({ id: "1cat", value: "" }));
    expect(category(s)).not.toHaveProperty("options");
    expect(category(s).app1.options.name).toBe("App 1");
  });

  it("sets and removes the translation key of an application", () => {
    let s = reducer(
      state(),
      changeApplicationField({
        catid: "1cat",
        id: "app1",
        field: "translation",
        value: "myApp",
      })
    );
    expect(category(s).app1.options).toEqual({
      name: "App 1",
      translation: "myApp",
    });
    s = reducer(
      s,
      changeApplicationField({
        catid: "1cat",
        id: "app1",
        field: "translation",
        value: "",
      })
    );
    expect(category(s).app1.options).toEqual({ name: "App 1" });
  });
});
