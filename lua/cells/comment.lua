-- Modified from Comment.nvim by Vikas Raj
-- available at https://github.com/numToStr/Comment.nvim
--
-- Original license:
-- 
-- MIT License

-- Copyright (c) 2021 Vikas Raj

-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:

-- The above copyright notice and this permission notice shall be included in all
-- copies or substantial portions of the Software.

-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
-- SOFTWARE.

--- Commonly found commentstrings
local B = {
    cxx_l = '//%s',
    cxx_b = '/*%s*/',
    dbl_hash = '##%s',
    dash = '--%s',
    dash_bracket = '--[[%s]]',
    handlebars = '{{!--%s--}}',
    hash = '#%s',
    hash_bracket = '#[[%s]]',
    haskell_b = '{-%s-}',
    fsharp_b = '(*%s*)',
    html = '<!--%s-->',
    latex = '%%s',
    semicolon = ';%s',
    lisp_l = ';;%s',
    lisp_b = '#|%s|#',
    twig = '{#%s#}',
    vim = '"%s',
    lean_b = '/-%s-/',
    ruby_block = '=begin%s=end',
}

---Structure = { filetype = { linewise, blockwise } }
local COMMENTSTRINGS = {
    arduino = { B.cxx_l, B.cxx_b },
    applescript = { B.hash },
    asm = { B.hash },
    astro = { B.html },
    autohotkey = { B.semicolon, B.cxx_b },
    bash = { B.hash },
    beancount = { B.semicolon },
    bib = { B.latex },
    blueprint = { B.cxx_l }, -- Blueprint doesn't have block comments
    c = { B.cxx_l, B.cxx_b },
    cabal = { B.dash },
    cairo = { B.cxx_l },
    cmake = { B.hash, B.hash_bracket },
    conf = { B.hash },
    conkyrc = { B.dash, B.dash_bracket },
    coq = { B.fsharp_b, B.fsharp_b },
    cpp = { B.cxx_l, B.cxx_b },
    cs = { B.cxx_l, B.cxx_b },
    css = { B.cxx_b, B.cxx_b },
    cuda = { B.cxx_l, B.cxx_b },
    cue = { B.cxx_l },
    dart = { B.cxx_l, B.cxx_b },
    dhall = { B.dash, B.haskell_b },
    dnsmasq = { B.hash },
    dosbatch = { 'REM%s' },
    dot = { B.cxx_l, B.cxx_b },
    dts = { B.cxx_l, B.cxx_b },
    editorconfig = { B.hash },
    eelixir = { B.html, B.html },
    elixir = { B.hash },
    elm = { B.dash, B.haskell_b },
    elvish = { B.hash },
    faust = { B.cxx_l, B.cxx_b },
    fennel = { B.semicolon },
    fish = { B.hash },
    func = { B.lisp_l },
    fsharp = { B.cxx_l, B.fsharp_b },
    gdb = { B.hash },
    gdscript = { B.hash },
    gdshader = { B.cxx_l, B.cxx_b },
    gitignore = { B.hash },
    gleam = { B.cxx_l },
    glsl = { B.cxx_l, B.cxx_b },
    gnuplot = { B.hash, B.hash_bracket },
    go = { B.cxx_l, B.cxx_b },
    gomod = { B.cxx_l },
    graphql = { B.hash },
    groovy = { B.cxx_l, B.cxx_b },
    handlebars = { B.handlebars, B.handlebars },
    haskell = { B.dash, B.haskell_b },
    haxe = { B.cxx_l, B.cxx_b },
    hcl = { B.hash, B.cxx_b },
    heex = { B.html, B.html },
    html = { B.html, B.html },
    htmldjango = { B.html, B.html },
    hyprlang = { B.hash },
    idris = { B.dash, B.haskell_b },
    idris2 = { B.dash, B.haskell_b },
    ini = { B.hash },
    jai = { B.cxx_l, B.cxx_b },
    java = { B.cxx_l, B.cxx_b },
    javascript = { B.cxx_l, B.cxx_b },
    javascriptreact = { B.cxx_l, B.cxx_b },
    jq = { B.hash },
    jsonc = { B.cxx_l },
    jsonnet = { B.cxx_l, B.cxx_b },
    julia = { B.hash, '#=%s=#' },
    kdl = { B.cxx_l, B.cxx_b },
    kotlin = { B.cxx_l, B.cxx_b },
    lean = { B.dash, B.lean_b },
    lean3 = { B.dash, B.lean_b },
    lidris = { B.dash, B.haskell_b },
    lilypond = { B.latex, '%{%s%}' },
    lisp = { B.lisp_l, B.lisp_b },
    lua = { B.dash, B.dash_bracket },
    metalua = { B.dash, B.dash_bracket },
    luau = { B.dash, B.dash_bracket },
    markdown = { B.html, B.html },
    make = { B.hash },
    mbsyncrc = { B.dbl_hash },
    mermaid = { '%%%s' },
    meson = { B.hash },
    mojo = { B.hash },
    nextflow = { B.cxx_l, B.cxx_b },
    nim = { B.hash, '#[%s]#' },
    nix = { B.hash, B.cxx_b },
    nu = { B.hash },
    objc = { B.cxx_l, B.cxx_b },
    objcpp = { B.cxx_l, B.cxx_b },
    ocaml = { B.fsharp_b, B.fsharp_b },
    odin = { B.cxx_l, B.cxx_b },
    openscad = { B.cxx_l, B.cxx_b },
    plantuml = { "'%s", "/'%s'/" },
    purescript = { B.dash, B.haskell_b },
    puppet = { B.hash },
    python = { B.hash }, -- Python doesn't have block comments
    php = { B.cxx_l, B.cxx_b },
    prisma = { B.cxx_l },
    proto = { B.cxx_l, B.cxx_b },
    quarto = { B.html, B.html },
    r = { B.hash }, -- R doesn't have block comments
    racket = { B.lisp_l, B.lisp_b },
    rasi = { B.cxx_l, B.cxx_b },
    readline = { B.hash },
    reason = { B.cxx_l, B.cxx_b },
    rego = { B.hash },
    remind = { B.hash },
    rescript = { B.cxx_l, B.cxx_b },
    robot = { B.hash }, -- Robotframework doesn't have block comments
    ron = { B.cxx_l, B.cxx_b },
    ruby = { B.hash, B.ruby_block },
    rust = { B.cxx_l, B.cxx_b },
    sbt = { B.cxx_l, B.cxx_b },
    scala = { B.cxx_l, B.cxx_b },
    scss = { B.cxx_b, B.cxx_b },
    scheme = { B.lisp_l, B.lisp_b },
    sh = { B.hash },
    solidity = { B.cxx_l, B.cxx_b },
    supercollider = { B.cxx_l, B.cxx_b },
    sql = { B.dash, B.cxx_b },
    stata = { B.cxx_l, B.cxx_b },
    svelte = { B.html, B.html },
    swift = { B.cxx_l, B.cxx_b },
    sxhkdrc = { B.hash },
    systemverilog = { B.cxx_l, B.cxx_b },
    tablegen = { B.cxx_l, B.cxx_b },
    teal = { B.dash, B.dash_bracket },
    terraform = { B.hash, B.cxx_b },
    tex = { B.latex },
    template = { B.dbl_hash },
    tidal = { B.dash, B.haskell_b },
    tmux = { B.hash },
    toml = { B.hash },
    twig = { B.twig, B.twig },
    typescript = { B.cxx_l, B.cxx_b },
    typescriptreact = { B.cxx_l, B.cxx_b },
    typst = { B.cxx_l, B.cxx_b },
    v = { B.cxx_l, B.cxx_b },
    vala = { B.cxx_l, B.cxx_b },
    verilog = { B.cxx_l },
    vhdl = { B.dash },
    vim = { B.vim },
    vifm = { B.vim },
    vue = { B.html, B.html },
    wgsl = { B.cxx_l, B.cxx_b },
    xdefaults = { '!%s' },
    xml = { B.html, B.html },
    xonsh = { B.hash }, -- Xonsh doesn't have block comments
    yaml = { B.hash },
    yuck = { B.lisp_l },
    zig = { B.cxx_l }, -- Zig doesn't have block comments
}

local M = {}

function M.get_commentstrings(lang)
    local tuple = COMMENTSTRINGS[lang]
    if not tuple then
        return nil
    end
    return vim.deepcopy(tuple)
end

return M
