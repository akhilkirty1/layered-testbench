package i2c_pkg;
   import ncsu_pkg::*;
   `include "ncsu_macros.svh"

   `include "src/i2c_typedefs.svh"
   `include "src/i2c_configuration.svh"
   `include "src/i2c_transaction.svh"
   `include "src/i2c_driver.svh"
   `include "src/i2c_monitor.svh"
   `include "src/i2c_coverage.svh"
   `include "src/i2c_agent.svh"

   typedef enum {READ, WRITE} i2c_op_t;
   
endpackage


times in msec
 clock   self+sourced   self:  sourced script
 clock   elapsed:              other lines

000.006  000.006: --- NVIM STARTING ---
000.313  000.307: locale set
000.557  000.243: inits 1
000.568  000.011: window checked
003.460  002.892: parsing arguments
003.625  000.165: expanding arguments
003.646  000.021: inits 2
004.032  000.386: init highlight
004.033  000.001: waiting for UI
004.649  000.616: done waiting for UI
004.658  000.008: init screen for UI
004.672  000.014: init default mappings
004.755  000.083: init default autocommands
004.807  000.011  000.011: sourcing /usr/share/nvim/archlinux.vim
004.810  000.035  000.024: sourcing /etc/xdg/nvim/sysinit.vim
006.909  001.619  001.619: sourcing /home/mwglen/.local/share/nvim/site/autoload/plug.vim
016.218  000.029  000.029: sourcing /home/mwglen/.config/nvim/plugged/vim-nix/ftdetect/nix.vim
016.341  000.053  000.053: sourcing /home/mwglen/.config/nvim/plugged/rust.vim/ftdetect/rust.vim
016.431  000.016  000.016: sourcing /home/mwglen/.config/nvim/plugged/vim-fugitive/ftdetect/fugitive.vim
016.754  000.018  000.018: sourcing /home/mwglen/.config/nvim/plugged/nvim-treesitter/ftdetect/cooklang.vim
016.785  000.013  000.013: sourcing /home/mwglen/.config/nvim/plugged/nvim-treesitter/ftdetect/fusion.vim
016.814  000.014  000.014: sourcing /home/mwglen/.config/nvim/plugged/nvim-treesitter/ftdetect/gdresource.vim
016.843  000.014  000.014: sourcing /home/mwglen/.config/nvim/plugged/nvim-treesitter/ftdetect/gdscript.vim
016.870  000.012  000.012: sourcing /home/mwglen/.config/nvim/plugged/nvim-treesitter/ftdetect/glimmer.vim
016.909  000.011  000.011: sourcing /home/mwglen/.config/nvim/plugged/nvim-treesitter/ftdetect/glsl.vim
016.938  000.013  000.013: sourcing /home/mwglen/.config/nvim/plugged/nvim-treesitter/ftdetect/gowork.vim
016.970  000.017  000.017: sourcing /home/mwglen/.config/nvim/plugged/nvim-treesitter/ftdetect/graphql.vim
017.000  000.015  000.015: sourcing /home/mwglen/.config/nvim/plugged/nvim-treesitter/ftdetect/hack.vim
017.030  000.015  000.015: sourcing /home/mwglen/.config/nvim/plugged/nvim-treesitter/ftdetect/hcl.vim
017.059  000.012  000.012: sourcing /home/mwglen/.config/nvim/plugged/nvim-treesitter/ftdetect/heex.vim
017.086  000.012  000.012: sourcing /home/mwglen/.config/nvim/plugged/nvim-treesitter/ftdetect/hjson.vim
017.112  000.012  000.012: sourcing /home/mwglen/.config/nvim/plugged/nvim-treesitter/ftdetect/json5.vim
017.151  000.024  000.024: sourcing /home/mwglen/.config/nvim/plugged/nvim-treesitter/ftdetect/ledger.vim
017.178  000.011  000.011: sourcing /home/mwglen/.config/nvim/plugged/nvim-treesitter/ftdetect/nix.vim
017.203  000.010  000.010: sourcing /home/mwglen/.config/nvim/plugged/nvim-treesitter/ftdetect/prisma.vim
017.229  000.010  000.010: sourcing /home/mwglen/.config/nvim/plugged/nvim-treesitter/ftdetect/pug.vim
017.261  000.014  000.014: sourcing /home/mwglen/.config/nvim/plugged/nvim-treesitter/ftdetect/ql.vim
017.298  000.021  000.021: sourcing /home/mwglen/.config/nvim/plugged/nvim-treesitter/ftdetect/query.vim
017.328  000.013  000.013: sourcing /home/mwglen/.config/nvim/plugged/nvim-treesitter/ftdetect/surface.vim
017.353  000.009  000.009: sourcing /home/mwglen/.config/nvim/plugged/nvim-treesitter/ftdetect/teal.vim
017.380  000.011  000.011: sourcing /home/mwglen/.config/nvim/plugged/nvim-treesitter/ftdetect/tlaplus.vim
017.407  000.012  000.012: sourcing /home/mwglen/.config/nvim/plugged/nvim-treesitter/ftdetect/yang.vim
017.482  000.012  000.012: sourcing /home/mwglen/.config/nvim/plugged/orgmode/ftdetect/org.vim
017.509  000.011  000.011: sourcing /home/mwglen/.config/nvim/plugged/orgmode/ftdetect/org_archive.vim
017.621  000.013  000.013: sourcing /usr/share/vim/vimfiles/ftdetect/PKGBUILD.vim
017.646  000.010  000.010: sourcing /usr/share/vim/vimfiles/ftdetect/augeas.vim
017.681  000.020  000.020: sourcing /usr/share/vim/vimfiles/ftdetect/meson.vim
017.922  000.228  000.228: sourcing /usr/share/vim/vimfiles/ftdetect/vagrantfile.vim
018.393  000.298  000.298: sourcing /home/mwglen/.config/nvim/plugged/orgmode/ftdetect/filetype.lua
018.552  008.099  007.098: sourcing /usr/share/nvim/runtime/filetype.vim
018.678  000.034  000.034: sourcing /usr/share/nvim/runtime/ftplugin.vim
018.804  000.026  000.026: sourcing /usr/share/nvim/runtime/indent.vim
019.004  000.068  000.068: sourcing /usr/share/nvim/runtime/syntax/synload.vim
019.075  000.230  000.162: sourcing /usr/share/nvim/runtime/syntax/syntax.vim
020.347  000.048  000.048: sourcing /home/mwglen/.cache/wal/colors-wal.vim
021.450  002.289  002.242: sourcing /home/mwglen/.config/nvim/plugged/wal.vim/colors/wal.vim
028.301  023.475  011.177: sourcing /home/mwglen/.config/nvim/init.lua
028.330  000.066: sourcing vimrc file(s)
028.658  000.056  000.056: sourcing /home/mwglen/.config/nvim/plugged/vim-nix/plugin/nix.vim
028.844  000.077  000.077: sourcing /home/mwglen/.config/nvim/plugged/rust.vim/plugin/cargo.vim
028.907  000.042  000.042: sourcing /home/mwglen/.config/nvim/plugged/rust.vim/plugin/rust.vim
029.333  000.102  000.102: sourcing /home/mwglen/.config/nvim/plugged/vim-airline/autoload/airline/init.vim
029.882  000.170  000.170: sourcing /home/mwglen/.config/nvim/plugged/vim-airline/autoload/airline/parts.vim
030.121  000.036  000.036: sourcing /home/mwglen/.config/nvim/plugged/vim-airline/autoload/airline/formatter/short_path.vim
031.918  000.237  000.237: sourcing /home/mwglen/.config/nvim/plugged/vim-airline/autoload/airline/util.vim
032.017  003.016  002.472: sourcing /home/mwglen/.config/nvim/plugged/vim-airline/plugin/airline.vim
032.157  000.042  000.042: sourcing /home/mwglen/.config/nvim/plugged/vim-airline-themes/plugin/airline-themes.vim
032.583  000.146  000.146: sourcing /home/mwglen/.config/nvim/plugged/vim-gitgutter/autoload/gitgutter/utility.vim
032.877  000.098  000.098: sourcing /home/mwglen/.config/nvim/plugged/vim-gitgutter/autoload/gitgutter/highlight.vim
033.959  001.732  001.489: sourcing /home/mwglen/.config/nvim/plugged/vim-gitgutter/plugin/gitgutter.vim
034.438  000.367  000.367: sourcing /home/mwglen/.config/nvim/plugged/vim-surround/plugin/surround.vim
035.649  001.127  001.127: sourcing /home/mwglen/.config/nvim/plugged/vim-fugitive/plugin/fugitive.vim
035.875  000.121  000.121: sourcing /home/mwglen/.config/nvim/plugged/vim-commentary/plugin/commentary.vim
036.040  000.092  000.092: sourcing /home/mwglen/.config/nvim/plugged/vim-startify/plugin/startify.vim
036.122  000.018  000.018: sourcing /home/mwglen/.config/nvim/plugged/goyo.vim/plugin/goyo.vim
036.297  000.114  000.114: sourcing /home/mwglen/.config/nvim/plugged/ranger.vim/plugin/ranger.vim
037.290  000.922  000.922: sourcing /home/mwglen/.config/nvim/plugged/nvim-treesitter/plugin/nvim-treesitter.vim
037.425  000.019  000.019: sourcing /home/mwglen/.config/nvim/plugged/orgmode/plugin/orgmode.vim
038.375  000.429  000.429: sourcing /usr/share/nvim/runtime/plugin/gzip.vim
038.431  000.013  000.013: sourcing /usr/share/nvim/runtime/plugin/health.vim
038.656  000.205  000.205: sourcing /usr/share/nvim/runtime/plugin/man.vim
039.285  000.213  000.213: sourcing /usr/share/nvim/runtime/pack/dist/opt/matchit/plugin/matchit.vim
039.387  000.708  000.495: sourcing /usr/share/nvim/runtime/plugin/matchit.vim
039.572  000.137  000.137: sourcing /usr/share/nvim/runtime/plugin/matchparen.vim
040.470  000.872  000.872: sourcing /usr/share/nvim/runtime/plugin/netrwPlugin.vim
040.776  000.223  000.223: sourcing /usr/share/nvim/runtime/plugin/rplugin.vim
041.171  000.352  000.352: sourcing /usr/share/nvim/runtime/plugin/shada.vim
041.336  000.070  000.070: sourcing /usr/share/nvim/runtime/plugin/spellfile.vim
041.795  000.409  000.409: sourcing /usr/share/nvim/runtime/plugin/tarPlugin.vim
041.943  000.097  000.097: sourcing /usr/share/nvim/runtime/plugin/tohtml.vim
042.005  000.023  000.023: sourcing /usr/share/nvim/runtime/plugin/tutor.vim
042.425  000.394  000.394: sourcing /usr/share/nvim/runtime/plugin/zipPlugin.vim
043.119  003.110: loading rtp plugins
043.259  000.140: loading packages
043.726  000.466: loading after plugins
043.745  000.019: inits 3
046.018  002.273: reading ShaDa
046.682  000.337  000.337: sourcing /home/mwglen/.config/nvim/plugged/vim-airline/autoload/airline/extensions.vim
047.047  000.105  000.105: sourcing /home/mwglen/.config/nvim/plugged/vim-airline/autoload/airline/extensions/quickfix.vim
047.374  000.220  000.220: sourcing /home/mwglen/.config/nvim/plugged/vim-airline/autoload/airline.vim
047.694  000.093  000.093: sourcing /home/mwglen/.config/nvim/plugged/vim-airline/autoload/airline/extensions/netrw.vim
048.095  000.076  000.076: sourcing /home/mwglen/.config/nvim/plugged/vim-airline/autoload/airline/section.vim
048.584  000.242  000.242: sourcing /home/mwglen/.config/nvim/plugged/vim-airline/autoload/airline/highlighter.vim
048.902  001.012  000.694: sourcing /home/mwglen/.config/nvim/plugged/vim-airline/autoload/airline/extensions/term.vim
049.225  000.105  000.105: sourcing /home/mwglen/.config/nvim/plugged/vim-airline/autoload/airline/extensions/hunks.vim
049.682  000.268  000.268: sourcing /home/mwglen/.config/nvim/plugged/vim-airline/autoload/airline/extensions/branch.vim
050.076  000.100  000.100: sourcing /home/mwglen/.config/nvim/plugged/vim-airline/autoload/airline/extensions/fugitiveline.vim
059.314  000.103  000.103: sourcing /home/mwglen/.config/nvim/plugged/vim-airline/autoload/airline/extensions/nvimlsp.vim
059.577  000.106  000.106: sourcing /home/mwglen/.config/nvim/plugged/vim-airline/autoload/airline/extensions/whitespace.vim
060.021  000.055  000.055: sourcing /home/mwglen/.config/nvim/plugged/vim-airline/autoload/airline/extensions/po.vim
060.183  000.071  000.071: sourcing /home/mwglen/.config/nvim/plugged/vim-airline/autoload/airline/extensions/wordcount.vim
060.343  000.026  000.026: sourcing /home/mwglen/.config/nvim/plugged/vim-airline/autoload/airline/extensions/keymap.vim
060.561  000.039  000.039: sourcing /home/mwglen/.config/nvim/plugged/vim-airline/autoload/airline/extensions/searchcount.vim
068.109  000.051  000.051: sourcing /home/mwglen/.config/nvim/plugged/vim-airline/autoload/airline/themes.vim
068.326  000.335  000.284: sourcing /home/mwglen/.config/nvim/plugged/wal.vim/autoload/airline/themes/wal.vim
084.543  000.124  000.124: sourcing /home/mwglen/.config/nvim/plugged/vim-airline/autoload/airline/builder.vim
084.917  000.069  000.069: sourcing /home/mwglen/.config/nvim/plugged/vim-airline/autoload/airline/extensions/default.vim
135.684  086.497: opening buffers
135.927  000.113  000.113: sourcing /home/mwglen/.config/nvim/plugged/vim-gitgutter/autoload/gitgutter.vim
136.151  000.355: BufEnter autocommands
136.154  000.003: editing files in windows
145.265  008.942  008.942: sourcing /home/mwglen/.config/nvim/plugged/vim-startify/autoload/startify.vim
146.271  000.636  000.636: sourcing /home/mwglen/.config/nvim/plugged/vim-startify/autoload/startify/fortune.vim
152.995  000.220  000.220: sourcing /usr/share/nvim/runtime/autoload/provider/clipboard.vim
155.417  000.422  000.422: sourcing /home/mwglen/.config/nvim/plugged/vim-startify/syntax/startify.vim
160.206  013.832: VimEnter autocommands
160.220  000.014: UIEnter autocommands
160.226  000.006: before starting main loop
173.981  013.755: first screen update
173.989  000.007: --- NVIM STARTED ---
