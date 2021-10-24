#!/bin/bash

# ----------------------
# Color Variables
# ----------------------
RED="\033[0;31m"
YELLOW='\033[1;33m'
GREEN='\033[1;32m'
LCYAN='\033[1;36m'
NC='\033[0m' # No Color

# --------------------------------------
# Prompts for configuration preferences
# --------------------------------------

# Package Manager Prompt
echo
echo "Which package manager are you using?"
select package_command_choices in "Yarn" "Yarn Workspaces" "npm" "Cancel"; do
  case $package_command_choices in
    Yarn ) pkg_cmd='yarn add'; break;;
    "Yarn Workspaces" ) pkg_cmd='yarn add -W'; break;;
    npm ) pkg_cmd='npm install'; break;;
    Cancel ) exit;;
  esac
done
echo

# File Format Prompt
echo "Which ESLint and Prettier configuration format do you prefer?"
select config_extension in ".js" ".json" "Cancel"; do
  case $config_extension in
    .js ) config_opening='module.exports = {'; break;;
    .json ) config_opening='{'; break;;
    Cancel ) exit;;
  esac
done
echo

# Checks for existing eslintrc files
if [ -f ".eslintrc.js" -o -f ".eslintrc.yaml" -o -f ".eslintrc.yml" -o -f ".eslintrc.json" -o -f ".eslintrc" ]; then
  echo -e "${RED}Existing ESLint config file(s) found:${NC}"
  ls -a .eslint* | xargs -n 1 basename
  echo
  echo -e "${RED}CAUTION:${NC} there is loading priority when more than one config file is present: https://eslint.org/docs/user-guide/configuring#configuration-file-formats"
  echo
  read -p  "Write .eslintrc${config_extension} (Y/n)? "
  if [[ $REPLY =~ ^[Nn]$ ]]; then
    echo -e "${YELLOW}>>>>> Skipping ESLint config${NC}"
    skip_eslint_setup="true"
  fi
fi
finished=false

# Max Line Length Prompt
while ! $finished; do
  read -p "What max line length do you want to set for ESLint and Prettier? (Default Recommendation: 80) "
  if [[ $REPLY =~ ^[0-9]{2,3}$ ]]; then
    max_len_val=$REPLY
    finished=true
    echo
  else
    echo -e "${YELLOW}Setting default value to 80${NC}"
    max_len_val=80
  fi
    finished=true
    echo
done

# Trailing Commas Prompt
echo "What style of trailing commas do you want to enforce with Prettier?"
echo -e "${YELLOW}>>>>> See https://prettier.io/docs/en/options.html#trailing-commas for more details.${NC}"
select trailing_comma_pref in "none" "es5" "all"; do
  case $trailing_comma_pref in
    none ) break;;
    es5 ) break;;
    all ) break;;
  esac
done
echo

# Checks for existing prettierrc files
if [ -f ".prettierrc.js" -o -f "prettier.config.js" -o -f ".prettierrc.yaml" -o -f ".prettierrc.yml" -o -f ".prettierrc.json" -o -f ".prettierrc.toml" -o -f ".prettierrc" -o -f ".prettierrc" ]; then
  echo -e "${RED}Existing Prettier config file(s) found${NC}"
  ls -a | grep "prettier*" | xargs -n 1 basename
  echo
  echo -e "${RED}CAUTION:${NC} The configuration file will be resolved starting from the location of the file being formatted, and searching up the file tree until a config file is (or isn't) found. https://prettier.io/docs/en/configuration.html"
  echo
  read -p  "Write .prettierrc${config_extension} (Y/n)? "
  if [[ $REPLY =~ ^[Nn]$ ]]; then
    echo -e "${YELLOW}>>>>> Skipping Prettier config${NC}"
    skip_prettier_setup="true"
  fi
  echo
fi

# Checks for existing stylelint files
if [ -f ".stylelintrc.js" -o -f "stylelintrc.config.js" -o -f ".stylelintrc.yaml" -o -f ".stylelintrc.yml" -o -f ".stylelintrc.json" -o -f ".stylelintrc.toml" -o -f ".stylelintrc" -o -f ".stylelintrc" ]; then
  echo -e "${RED}Existing Stylelint config file(s) found${NC}"
  ls -a | grep "stylelint*" | xargs -n 1 basename
  echo
  echo -e "${RED}CAUTION:${NC} The configuration file will be resolved starting from the location of the file being formatted, and searching up the file tree until a config file is (or isn't) found. https://stylelint.io/user-guide/configure"
  echo
  read -p  "Write .stylelintrc${config_extension} (Y/n)? "
  if [[ $REPLY =~ ^[Nn]$ ]]; then
    echo -e "${YELLOW}>>>>> Skipping Stylelint config${NC}"
    skip_stylelint_setup="true"
  fi
  echo
fi

# ----------------------
# Perform Configuration
# ----------------------
echo
echo -e "${GREEN}Configuring your development environment... ${NC}"

echo
echo -e "1/8 ${LCYAN}ESLint/Prettier/Stylelint Installation... ${NC}"
echo
$pkg_cmd -D eslint prettier stylelint

echo
echo -e "2/8 ${LCYAN}Conforming to Airbnb's JavaScript/CSS Style Guide... ${NC}"
echo
$pkg_cmd -D eslint-config-airbnb eslint-config-airbnb-typescript eslint-config-prettier stylelint-config-prettier stylelint-config-recommended

echo
echo -e "3/8 ${LCYAN}Making ESlint/Stylelint and Prettier play nice with each other... ${NC}"
echo "See https://github.com/prettier/eslint-config-prettier for more details."
echo
$pkg_cmd -D eslint-plugin-prettier stylelint-prettier stylelint-config-prettier eslint-config-prettier

echo
echo -e "4/8 ${LCYAN}Others Plugins Installation... ${NC}"
echo
$pkg_cmd -D eslint-plugin-simple-import-sort eslint-plugin-better-styled-components eslint-plugin-chai-friendly eslint-plugin-cypress eslint-plugin-import eslint-plugin-jsx-a11y eslint-plugin-react eslint-plugin-react-hooks

if [ "$skip_eslint_setup" == "true" ]; then
  break
else
  echo
  echo -e "5/8 ${YELLOW}Building your .eslintrc${config_extension} file...${NC}"
  > ".eslintrc${config_extension}" # truncates existing file (or creates empty)

  echo ${config_opening}'
  "env": {
    "browser": true,
    "es2021": true,
    "jest": true
  },
  "extends": [
    "plugin:react/recommended",
    "airbnb",
    "airbnb/hooks",
    "prettier"
  ],
  "parser": "babel-eslint",
  "parserOptions": {
    "ecmaFeatures": {
      "jsx": true
    },
    "ecmaVersion": 12,
    "sourceType": "module"
  },
  "plugins": ["react", "prettier", "simple-import-sort", "better-styled-components"],
  "rules": {
    "simple-import-sort/sort": "warn",
    "better-styled-components/sort-declarations-alphabetically": 2,
    "react/jsx-filename-extension": [
      "error",
      {
        "extensions": [".js", ".jsx", ".ts", ".tsx"]
      }
    ],
    "prettier/prettier": "error",
    "no-param-reassign": 0,
    "import/extensions": [
      "error",
      "ignorePackages",
      {
        "js": "never",
        "jsx": "never",
        "ts": "never",
        "tsx": "never"
      }
    ]
  },
  "settings": {
    "import/resolver": {
      "node": {
        "extensions": [".js", ".jsx", ".ts", ".tsx"]
      }
    }
  }
}' >> .eslintrc${config_extension}
fi


if [ "$skip_prettier_setup" == "true" ]; then
  break
else
  echo -e "6/8 ${YELLOW}Building your .prettierrc${config_extension} file... ${NC}"
  > .prettierrc${config_extension} # truncates existing file (or creates empty)

  echo ${config_opening}'
  "printWidth": '${max_len_val}',
  "singleQuote": true,
  "trailingComma": "'${trailing_comma_pref}'"
}' >> .prettierrc${config_extension}
fi


if [ "$skip_stylelint_setup" == "true" ]; then
  break
else
  echo
  echo -e "7/8 ${YELLOW}Building your .stylelintrc${config_extension} file...${NC}"
  > ".stylelintrc${config_extension}" # truncates existing file (or creates empty)

  echo ${config_opening}'
  "extends": ["stylelint-config-recommended", "stylelint-config-prettier"],
  "rules": {
    "at-rule-no-unknown": [
      true,
      {
        "ignoreAtRules": [
          "tailwind",
          "apply",
          "variants",
          "responsive",
          "screen"
        ]
      }
    ],
    "declaration-block-trailing-semicolon": null,
    "no-descending-specificity": null
  }
}' >> .stylelintrc${config_extension}
fi

echo -e "8/8 ${YELLOW}Building your .editorconfig file... ${NC}"
  > .editorconfig # truncates existing file (or creates empty)

  echo '
  root = true

[*]
indent_style = space
indent_size = 2
end_of_line = lf
charset = utf-8
trim_trailing_whitespace = true
insert_final_newline = true
' >> .editorconfig

> [.e2e].eslintrc.json

  echo ${config_opening}'
    "plugins": ["cypress", "chai-friendly"],
  "extends": ["plugin:cypress/recommended", "plugin:chai-friendly/recommended"]
}' >> [.e2e].eslintrc.json

echo
echo -e "${GREEN}Finished setting up!${NC}"
echo
