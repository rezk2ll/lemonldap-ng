/**
 * rollup configuration file that reproduce `react-scripts build`
 *
 * @copyright Yadd <yadd@debian.org>
 * license MIT
 */
import babel from "@rollup/plugin-babel";
import commonjs from "@rollup/plugin-commonjs";
import html from "@rollup/plugin-html";
import image from "@rollup/plugin-image";
import inject from "@rollup/plugin-inject";
import json from "@rollup/plugin-json";
import { nodeResolve } from "@rollup/plugin-node-resolve";
import replace from "@rollup/plugin-replace";
import svgr from "@svgr/rollup";
import postcssModules from "postcss-modules";
import postcssPresetEnv from "postcss-preset-env";
import postcss from "rollup-plugin-postcss";
import typescript from "@rollup/plugin-typescript";
<<<<<<< HEAD
import terser from "@rollup/plugin-terser";
import progress from "rollup-plugin-progress";

// https://github.com/d3/d3-interpolate/issues/58
const D3_WARNING = /Circular dependency.*d3-interpolate/;
=======
import { terser } from "rollup-plugin-terser";
>>>>>>> ebe89c824 (Avoid error with some rollup)

export default {
  input: ["src/index.tsx"],
  output: {
    dir: "dist",
    format: "iife",
    sourcemap: true,
    entryFileNames: "static/manager-[hash].js",
    inlineDynamicImports: true,
<<<<<<< HEAD
    sourcemap: true, // Ensure source maps are generated
  },
  onwarn(warning, warn) {
    if (D3_WARNING.test(warning)) {
      return;
    }
    if (warning.code === "THIS_IS_UNDEFINED") {
      return;
    }
    if (warning.code === "MODULE_LEVEL_DIRECTIVE") {
      return;
    }

    warn(warning);
  },
  plugins: [
    progress(),
=======
  },
  plugins: [
>>>>>>> ebe89c824 (Avoid error with some rollup)
    svgr(),
    image(),
    nodeResolve({
      browser: true,
      extensions: [".js", ".ts", ".jsx", ".tsx"],
    }),
    babel({
      presets: ["@babel/env", "@babel/preset-react"],
      plugins: ["@babel/plugin-transform-react-jsx"],
      babelHelpers: "bundled",
    }),
    json(),
    replace({
      "process.env.NODE_ENV":
        process.env.NODE_ENV === "development"
          ? JSON.stringify("development")
          : JSON.stringify("production"),
      preventAssignment: true,
<<<<<<< HEAD
      "process.env.REACT_APP_HTMLNAME": '"manager.new.html"',
=======
      "process.env.REACT_APP_HTMLNAME": '"newmanager.html"',
>>>>>>> ebe89c824 (Avoid error with some rollup)
    }),
    typescript({
      tsconfig: "./tsconfig.build.json",
      declaration: true,
      declarationDir: "dist",
    }),
    postcss({
      plugins: [
        postcssModules({
          generateScopedName: "[local]",
        }),
        postcssPresetEnv({
          stage: 0,
        }),
      ],
    }),
    commonjs(),
    inject({
      React: "react",
    }),
    html({
      fileName: "index.html",
<<<<<<< HEAD
      title: "Lemonldap react Manager built with rollup",
=======
      title: "React app built with rollup",
>>>>>>> ebe89c824 (Avoid error with some rollup)
      template: ({ attributes, bundle, files, publicPath, title }) => {
        let scripts = "";
        files.js.forEach((bundle) => {
          scripts += `<script src="${bundle.fileName}"></script>`;
        });
<<<<<<< HEAD

        const makeAttrs = (attrs = {}) =>
          Object.entries(attrs)
            .map(([key, value]) => `${key}="${value}"`)
            .join(" ");

        return `<!DOCTYPE html>
<html ${makeAttrs(attributes.html)}>
  <head>
    <title>${title}</title>
    <link rel="icon" href="/static/logos/favicon.ico" />
  </head>
  <body>
    <div id="root" />
    ${scripts}
=======
        return `<!DOCTYPE html>
<html ${JSON.stringify(attributes)}>
  <head>
    <title>${title}</title>
  </head>
  <body>
   <div id="root" />
   ${scripts}
>>>>>>> ebe89c824 (Avoid error with some rollup)
  </body>
</html>`;
      },
    }),
<<<<<<< HEAD
    terser(),
  ],
=======
    // terser(),
  ]
>>>>>>> ebe89c824 (Avoid error with some rollup)
};
