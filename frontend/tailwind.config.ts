import type { Config } from "tailwindcss";

const config: Config = {
  content: [
    "./src/pages/**/*.{js,ts,jsx,tsx,mdx}",
    "./src/components/**/*.{js,ts,jsx,tsx,mdx}",
    "./src/app/**/*.{js,ts,jsx,tsx,mdx}",
  ],
  theme: {
    extend: {
      colors: {
        'theme-orange': '#ffa69e',
        'theme-drk-orange': '#ee9191',
        'theme-lgt-green': '#ddfff7',
        'theme-drk-green': '#93e1d8',
        'theme-pressed-green': '#7ac7b8',
      },
    },
  },
  plugins: [],
};
export default config;
