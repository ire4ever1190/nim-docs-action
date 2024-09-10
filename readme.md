Simple action to build documentation. Deployment needs to be done
separately.

### Features
- [x] Removes `src/` prefix from pages
- [x] Sets commit information for docs
- [x] Checksout the tag so you are building for the latest release (Instead of just the latest development changes)
- [x] Builds indexes first to support `importdoc`
- [x] Can deploy files to Github pages
- [ ] TODO: Build both devel/stable docs

## Setup

### Action
Add this line into your build step somewhere
```yml
      - name: "Build documentation"
        uses: "ire4ever1190/nim-docs-action@v1"
        with:
          main-file: src/foo.nim # Replace with your main file
```

Full example to auto deploy to Github pages

```yml
on:
  push:
    branches:
      - master # Replace this with your main branch
  workflow_dispatch: # Enable manually rebuilding docs

jobs:
  deploy:
    permissions:
      pages: write # To deploy to Pages
      id-token: write # Verify deployment
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: "Setup nim"
        uses: jiro4989/setup-nim-action@v2
        with:
          repo-token: ${{ secrets.GITHUB_TOKEN }}

      - name: "Build documentation"
        uses: ire4ever1190/nim-docs-action@v1
        with:
          main-file: "src/pantry.nim"
          deploy: "pages"
```

### Config

#### Inputs

Only `main-file` is required. Everything else is optional

- `main-file`: Entry point to your library. Builds documentation starting from this (required)
- `out-dir`: Folder to put documentation into
- `project-dir`: Folder containing the .nimble file. Used as working directory for operations
- `build-index`: Whether to build index before building documentation. This is only to support [referencing external symbols](https://nim-lang.org/docs/markdown_rst.html#referencing-markup-external-referencing). If you don't use that then you can turn this off (theindex.html will be built either way)
- `deploy`: Automatically deploy the documentation. Currently only supports 'pages'

#### Outputs

- `site-dir`: Path to directory containing the built documentation

#### Nim

`-d:docgen` is passed when compiling files so you can use that within your config files to conditionally enable docgen flags
