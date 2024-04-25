Simple neovim plugin for nuget package management

## Setup
Add the following to your lazy.nvim setup
```lua
{
    'pgdanes/nug.nvim',
    config = function()
        require('nug')
    end
}
```

## User commands

### :NugPackages
List all nuget package references in current directories csproj (and all nested)
