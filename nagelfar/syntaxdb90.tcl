# Automatically generated syntax database.

lappend ::dbInfo {Tcl 9.0a4 unix, Tk 8.7a6 x11}
set ::dbTclVersion 9.0
set ::knownGlobals {argc argv argv0 auto_index auto_path env errorCode errorInfo tcl_interactive tcl_library tcl_nonwordchars tcl_patchLevel tcl_pkgPath tcl_platform tcl_rcFileName tcl_version tcl_wordchars test tk_library tk_patchLevel tk_strictMotif tk_version}
set ::knownCommands {
.
EvalAttached
after
append
apply
array
auto_execok
auto_import
auto_load
auto_load_index
auto_mkindex
auto_mkindex_old
auto_mkindex_parser::childhook
auto_mkindex_parser::cleanup
auto_mkindex_parser::command
auto_mkindex_parser::commandInit
auto_mkindex_parser::fullname
auto_mkindex_parser::hook
auto_mkindex_parser::indexEntry
auto_mkindex_parser::init
auto_mkindex_parser::mkindex
auto_qualify
auto_reset
bell
bgerror
binary
bind
bindtags
break
button
canvas
catch
cd
chan
checkbutton
clipboard
clock
close
concat
continue
coroinject
coroprobe
coroutine
destroy
dict
encoding
entry
eof
error
eval
event
exec
exit
expr
fblocked
fconfigure
fcopy
file
fileevent
flush
focus
font
for
foreach
format
fpclassify
frame
gets
glob
global
grab
grid
history
if
image
image1
image2
image3
incr
info
interp
join
label
labelframe
lappend
lassign
ledit
lindex
linsert
list
listbox
llength
lmap
load
lower
lpop
lrange
lremove
lrepeat
lreplace
lreverse
lsearch
lseq
lset
lsort
menu
menubutton
message
msgcat::mc
msgcat::mcexists
msgcat::mcflmset
msgcat::mcflset
msgcat::mcforgetpackage
msgcat::mcload
msgcat::mcloadedlocales
msgcat::mclocale
msgcat::mcmax
msgcat::mcmset
msgcat::mcn
msgcat::mcpackageconfig
msgcat::mcpackagelocale
msgcat::mcpackagenamespaceget
msgcat::mcpreferences
msgcat::mcset
msgcat::mcunknown
msgcat::mcutil
msgcat::mcutil::getpreferences
msgcat::mcutil::getsystemlocale
my
namespace
oo::abstract
oo::class
oo::configurable
oo::copy
oo::define
oo::objdefine
oo::object
oo::singleton
open
option
pack
package
panedwindow
parray
pid
pkg::create
pkg_mkIndex
place
proc
puts
pwd
radiobutton
raise
read
regexp
regsub
rename
return
safe::interpAddToAccessPath
safe::interpConfigure
safe::interpCreate
safe::interpDelete
safe::interpFindInAccessPath
safe::interpInit
safe::setLogCmd
scale
scan
scrollbar
seek
selection
self
send
set
socket
source
spinbox
split
string
subst
switch
tailcall
tcl::Lassign
tcl::Lempty
tcl::Lget
tcl::Lvarincr
tcl::Lvarpop
tcl::Lvarpop1
tcl::Lvarset
tcl::OptKeyDelete
tcl::OptKeyError
tcl::OptKeyParse
tcl::OptKeyRegister
tcl::OptParse
tcl::OptProc
tcl::OptProcArgGiven
tcl::Pkg::source
tcl::SetMax
tcl::SetMin
tcl::array::anymore
tcl::array::default
tcl::array::donesearch
tcl::array::exists
tcl::array::for
tcl::array::get
tcl::array::names
tcl::array::nextelement
tcl::array::set
tcl::array::size
tcl::array::startsearch
tcl::array::statistics
tcl::array::unset
tcl::binary::decode
tcl::binary::decode::base64
tcl::binary::decode::hex
tcl::binary::decode::uuencode
tcl::binary::encode
tcl::binary::encode::base64
tcl::binary::encode::hex
tcl::binary::encode::uuencode
tcl::binary::format
tcl::binary::scan
tcl::build-info
tcl::chan::blocked
tcl::chan::close
tcl::chan::copy
tcl::chan::create
tcl::chan::eof
tcl::chan::event
tcl::chan::flush
tcl::chan::gets
tcl::chan::names
tcl::chan::pending
tcl::chan::pipe
tcl::chan::pop
tcl::chan::postevent
tcl::chan::push
tcl::chan::puts
tcl::chan::read
tcl::chan::seek
tcl::chan::tell
tcl::chan::truncate
tcl::clock::add
tcl::clock::clicks
tcl::clock::format
tcl::clock::getenv
tcl::clock::microseconds
tcl::clock::milliseconds
tcl::clock::scan
tcl::clock::seconds
tcl::dict::append
tcl::dict::create
tcl::dict::exists
tcl::dict::filter
tcl::dict::for
tcl::dict::get
tcl::dict::getdef
tcl::dict::getwithdefault
tcl::dict::incr
tcl::dict::info
tcl::dict::keys
tcl::dict::lappend
tcl::dict::map
tcl::dict::merge
tcl::dict::remove
tcl::dict::replace
tcl::dict::set
tcl::dict::size
tcl::dict::unset
tcl::dict::update
tcl::dict::values
tcl::dict::with
tcl::encoding::convertfrom
tcl::encoding::convertto
tcl::encoding::dirs
tcl::encoding::names
tcl::encoding::profiles
tcl::encoding::system
tcl::file::atime
tcl::file::attributes
tcl::file::channels
tcl::file::copy
tcl::file::delete
tcl::file::dirname
tcl::file::executable
tcl::file::exists
tcl::file::extension
tcl::file::home
tcl::file::isdirectory
tcl::file::isfile
tcl::file::join
tcl::file::link
tcl::file::lstat
tcl::file::mkdir
tcl::file::mtime
tcl::file::nativename
tcl::file::normalize
tcl::file::owned
tcl::file::pathtype
tcl::file::readable
tcl::file::readlink
tcl::file::rename
tcl::file::rootname
tcl::file::separator
tcl::file::size
tcl::file::split
tcl::file::stat
tcl::file::system
tcl::file::tail
tcl::file::tempdir
tcl::file::tempfile
tcl::file::tildeexpand
tcl::file::type
tcl::file::volumes
tcl::file::writable
tcl::history
tcl::info::args
tcl::info::body
tcl::info::cmdcount
tcl::info::cmdtype
tcl::info::commands
tcl::info::complete
tcl::info::coroutine
tcl::info::default
tcl::info::errorstack
tcl::info::exists
tcl::info::frame
tcl::info::functions
tcl::info::globals
tcl::info::hostname
tcl::info::level
tcl::info::library
tcl::info::loaded
tcl::info::locals
tcl::info::nameofexecutable
tcl::info::patchlevel
tcl::info::procs
tcl::info::script
tcl::info::sharedlibextension
tcl::info::tclversion
tcl::info::vars
tcl::mathfunc::abs
tcl::mathfunc::acos
tcl::mathfunc::asin
tcl::mathfunc::atan
tcl::mathfunc::atan2
tcl::mathfunc::bool
tcl::mathfunc::ceil
tcl::mathfunc::cos
tcl::mathfunc::cosh
tcl::mathfunc::double
tcl::mathfunc::entier
tcl::mathfunc::exp
tcl::mathfunc::floor
tcl::mathfunc::fmod
tcl::mathfunc::hypot
tcl::mathfunc::int
tcl::mathfunc::isfinite
tcl::mathfunc::isinf
tcl::mathfunc::isnan
tcl::mathfunc::isnormal
tcl::mathfunc::isqrt
tcl::mathfunc::issubnormal
tcl::mathfunc::isunordered
tcl::mathfunc::log
tcl::mathfunc::log10
tcl::mathfunc::max
tcl::mathfunc::min
tcl::mathfunc::pow
tcl::mathfunc::rand
tcl::mathfunc::round
tcl::mathfunc::sin
tcl::mathfunc::sinh
tcl::mathfunc::sqrt
tcl::mathfunc::srand
tcl::mathfunc::tan
tcl::mathfunc::tanh
tcl::mathfunc::wide
tcl::mathop::!
tcl::mathop::!=
tcl::mathop::%
tcl::mathop::&
tcl::mathop::*
tcl::mathop::**
tcl::mathop::+
tcl::mathop::-
tcl::mathop::/
tcl::mathop::<
tcl::mathop::<<
tcl::mathop::<=
tcl::mathop::==
tcl::mathop::>
tcl::mathop::>=
tcl::mathop::>>
tcl::mathop::^
tcl::mathop::eq
tcl::mathop::ge
tcl::mathop::gt
tcl::mathop::in
tcl::mathop::le
tcl::mathop::lt
tcl::mathop::ne
tcl::mathop::ni
tcl::mathop::|
tcl::mathop::~
tcl::namespace::children
tcl::namespace::code
tcl::namespace::current
tcl::namespace::delete
tcl::namespace::ensemble
tcl::namespace::eval
tcl::namespace::exists
tcl::namespace::export
tcl::namespace::forget
tcl::namespace::import
tcl::namespace::inscope
tcl::namespace::origin
tcl::namespace::parent
tcl::namespace::path
tcl::namespace::qualifiers
tcl::namespace::tail
tcl::namespace::unknown
tcl::namespace::upvar
tcl::namespace::which
tcl::pkgconfig
tcl::prefix
tcl::prefix
tcl::prefix::all
tcl::prefix::longest
tcl::prefix::match
tcl::process
tcl::process
tcl::process::autopurge
tcl::process::list
tcl::process::purge
tcl::process::status
tcl::string::cat
tcl::string::compare
tcl::string::equal
tcl::string::first
tcl::string::index
tcl::string::insert
tcl::string::is
tcl::string::last
tcl::string::length
tcl::string::map
tcl::string::match
tcl::string::range
tcl::string::repeat
tcl::string::replace
tcl::string::reverse
tcl::string::tolower
tcl::string::totitle
tcl::string::toupper
tcl::string::trim
tcl::string::trimleft
tcl::string::trimright
tcl::string::wordend
tcl::string::wordstart
tcl::tm::path
tcl::unsupported::assemble
tcl::unsupported::corotype
tcl::unsupported::disassemble
tcl::unsupported::getbytecode
tcl::unsupported::inject
tcl::unsupported::representation
tcl::zipfs::canonical
tcl::zipfs::exists
tcl::zipfs::find
tcl::zipfs::info
tcl::zipfs::list
tcl::zipfs::lmkimg
tcl::zipfs::lmkzip
tcl::zipfs::mkimg
tcl::zipfs::mkkey
tcl::zipfs::mkzip
tcl::zipfs::mount
tcl::zipfs::mount_data
tcl::zipfs::root
tcl::zipfs::tcl_library_init
tcl::zipfs::unmount
tclListValidFlags
tclLog
tclParseConfigSpec
tclPkgSetup
tclPkgUnknown
tcl_endOfWord
tcl_findLibrary
tcl_startOfNextWord
tcl_startOfPreviousWord
tcl_wordBreakAfter
tcl_wordBreakBefore
tell
text
throw
time
timerate
tk
tk::ScaleNum
tk::ScalingPct
tk::button
tk::canvas
tk::checkbutton
tk::classic::restore
tk::classic::restore_button
tk::classic::restore_entry
tk::classic::restore_font
tk::classic::restore_listbox
tk::classic::restore_menu
tk::classic::restore_menubutton
tk::classic::restore_message
tk::classic::restore_panedwindow
tk::classic::restore_scale
tk::classic::restore_scrollbar
tk::classic::restore_text
tk::dialog::b1
tk::dialog::b2
tk::dialog::color::mc
tk::dialog::color::mcmax
tk::dialog::error::bgerror
tk::dialog::file::chooseDir::mc
tk::dialog::file::chooseDir::mcmax
tk::dialog::file::mc
tk::dialog::file::mcmax
tk::dialog::i
tk::dialog::q
tk::dialog::w1
tk::dialog::w2
tk::dialog::w3
tk::entry
tk::fontchooser::ttk_slistbox
tk::frame
tk::icons::error
tk::icons::information
tk::icons::question
tk::icons::warning
tk::label
tk::labelframe
tk::listbox
tk::menubutton
tk::message
tk::msgcat::mc
tk::msgcat::mcmax
tk::panedwindow
tk::ps::function
tk::ps::literal
tk::ps::variable
tk::radiobutton
tk::scale
tk::scrollbar
tk::spinbox
tk::sysnotify::sysnotify
tk::systray::configure
tk::systray::create
tk::systray::destroy
tk::systray::exists
tk::text
tk::toplevel
tk_bindForTraversal
tk_bisque
tk_chooseColor
tk_chooseDirectory
tk_dialog
tk_focusFollowsMouse
tk_focusNext
tk_focusPrev
tk_getOpenFile
tk_getSaveFile
tk_menuBar
tk_menuSetFocus
tk_messageBox
tk_optionMenu
tk_popup
tk_setPalette
tk_textCopy
tk_textCut
tk_textPaste
tkwait
toplevel
trace
try
ttk::button
ttk::button::activate
ttk::checkbutton
ttk::combobox
ttk::entry
ttk::frame
ttk::label
ttk::labelframe
ttk::menubutton
ttk::notebook
ttk::notebook::enableTraversal
ttk::panedwindow
ttk::progressbar
ttk::progressbar::start
ttk::progressbar::stop
ttk::radiobutton
ttk::scale
ttk::scrollbar
ttk::separator
ttk::setTheme
ttk::sizegrip
ttk::style
ttk::theme::default::reconfigureDefaultTheme
ttk::themes
ttk::treeview
ttk::treeview::between
ttk::treeview::heading.drag
ttk::treeview::heading.press
ttk::treeview::heading.release
ttk::treeview::resize.drag
ttk::treeview::resize.press
ttk::treeview::resize.release
ttk::treeview::select.choose.browse
ttk::treeview::select.choose.extended
ttk::treeview::select.choose.none
ttk::treeview::select.extend.browse
ttk::treeview::select.extend.extended
ttk::treeview::select.extend.none
ttk::treeview::select.toggle.browse
ttk::treeview::select.toggle.extended
ttk::treeview::select.toggle.none
unknown
unload
unset
update
uplevel
upvar
variable
vwait
while
winfo
wm
yield
yieldto
zipfs
zlib
zlib::pkgconfig
}
set ::knownPackages {Tcl TclOO Tk Ttk msgcat tile zlib}
set ::syntax(.) {s x*}
set {::syntax(. cget)} o
set {::syntax(. configure)} {o. x. p*}
set ::syntax(_obj,button) {s x*}
set {::syntax(_obj,button cget)} o
set {::syntax(_obj,button configure)} {o. x. p*}
set ::syntax(_obj,canvas) {s x*}
set {::syntax(_obj,canvas cget)} o
set {::syntax(_obj,canvas configure)} {o. x. p*}
set ::syntax(_obj,checkbutton) {s x*}
set {::syntax(_obj,checkbutton cget)} o
set {::syntax(_obj,checkbutton configure)} {o. x. p*}
set ::syntax(_obj,entry) {s x*}
set {::syntax(_obj,entry cget)} o
set {::syntax(_obj,entry configure)} {o. x. p*}
set ::syntax(_obj,frame) {s x*}
set {::syntax(_obj,frame cget)} o
set {::syntax(_obj,frame configure)} {o. x. p*}
set ::syntax(_obj,label) {s x*}
set {::syntax(_obj,label cget)} o
set {::syntax(_obj,label configure)} {o. x. p*}
set ::syntax(_obj,labelframe) {s x*}
set {::syntax(_obj,labelframe cget)} o
set {::syntax(_obj,labelframe configure)} {o. x. p*}
set ::syntax(_obj,listbox) {s x*}
set {::syntax(_obj,listbox cget)} o
set {::syntax(_obj,listbox configure)} {o. x. p*}
set {::syntax(_obj,listbox selection)} {s x x?}
set ::syntax(_obj,menu) {s x*}
set {::syntax(_obj,menu cget)} o
set {::syntax(_obj,menu configure)} {o. x. p*}
set ::syntax(_obj,menubutton) {s x*}
set {::syntax(_obj,menubutton cget)} o
set {::syntax(_obj,menubutton configure)} {o. x. p*}
set ::syntax(_obj,message) {s x*}
set {::syntax(_obj,message cget)} o
set {::syntax(_obj,message configure)} {o. x. p*}
set ::syntax(_obj,panedwindow) {s x*}
set {::syntax(_obj,panedwindow cget)} o
set {::syntax(_obj,panedwindow configure)} {o. x. p*}
set ::syntax(_obj,radiobutton) {s x*}
set {::syntax(_obj,radiobutton cget)} o
set {::syntax(_obj,radiobutton configure)} {o. x. p*}
set ::syntax(_obj,scale) {s x*}
set {::syntax(_obj,scale cget)} o
set {::syntax(_obj,scale configure)} {o. x. p*}
set ::syntax(_obj,scrollbar) {s x*}
set {::syntax(_obj,scrollbar cget)} o
set {::syntax(_obj,scrollbar configure)} {o. x. p*}
set ::syntax(_obj,spinbox) {s x*}
set {::syntax(_obj,spinbox cget)} o
set {::syntax(_obj,spinbox configure)} {o. x. p*}
set ::syntax(_obj,text) {s x*}
set {::syntax(_obj,text bbox)} 1
set {::syntax(_obj,text cget)} o
set {::syntax(_obj,text compare)} 3
set {::syntax(_obj,text configure)} {o. x. p*}
set {::syntax(_obj,text count)} {o* x x}
set {::syntax(_obj,text debug)} x?
set {::syntax(_obj,text delete)} {r 1}
set {::syntax(_obj,text dlineinfo)} 1
set {::syntax(_obj,text dump)} {o* x x?}
set {::syntax(_obj,text edit)} {s x*}
set {::syntax(_obj,text get)} {o* x x*}
set {::syntax(_obj,text image)} {s x*}
set {::syntax(_obj,text index)} 1
set {::syntax(_obj,text insert)} {r 2}
set {::syntax(_obj,text mark)} {s x*}
set {::syntax(_obj,text peer)} {s x*}
set {::syntax(_obj,text pendingsync)} 0
set {::syntax(_obj,text replace)} {r 3}
set {::syntax(_obj,text scan)} {s x x}
set {::syntax(_obj,text search)} {o* x x x?}
set {::syntax(_obj,text see)} 1
set {::syntax(_obj,text sync)} {r 1 3}
set {::syntax(_obj,text tag)} {s x*}
set {::syntax(_obj,text window)} {s x*}
set {::syntax(_obj,text xview)} {0: 0 : s x*}
set {::syntax(_obj,text yview)} x*
set ::syntax(_obj,tk::button) {s x*}
set {::syntax(_obj,tk::button cget)} o
set {::syntax(_obj,tk::button configure)} {o. x. p*}
set ::syntax(_obj,tk::canvas) {s x*}
set {::syntax(_obj,tk::canvas cget)} o
set {::syntax(_obj,tk::canvas configure)} {o. x. p*}
set ::syntax(_obj,tk::checkbutton) {s x*}
set {::syntax(_obj,tk::checkbutton cget)} o
set {::syntax(_obj,tk::checkbutton configure)} {o. x. p*}
set ::syntax(_obj,tk::entry) {s x*}
set {::syntax(_obj,tk::entry cget)} o
set {::syntax(_obj,tk::entry configure)} {o. x. p*}
set ::syntax(_obj,tk::frame) {s x*}
set {::syntax(_obj,tk::frame cget)} o
set {::syntax(_obj,tk::frame configure)} {o. x. p*}
set ::syntax(_obj,tk::label) {s x*}
set {::syntax(_obj,tk::label cget)} o
set {::syntax(_obj,tk::label configure)} {o. x. p*}
set ::syntax(_obj,tk::labelframe) {s x*}
set {::syntax(_obj,tk::labelframe cget)} o
set {::syntax(_obj,tk::labelframe configure)} {o. x. p*}
set ::syntax(_obj,tk::listbox) {s x*}
set {::syntax(_obj,tk::listbox cget)} o
set {::syntax(_obj,tk::listbox configure)} {o. x. p*}
set ::syntax(_obj,tk::menubutton) {s x*}
set {::syntax(_obj,tk::menubutton cget)} o
set {::syntax(_obj,tk::menubutton configure)} {o. x. p*}
set ::syntax(_obj,tk::message) {s x*}
set {::syntax(_obj,tk::message cget)} o
set {::syntax(_obj,tk::message configure)} {o. x. p*}
set ::syntax(_obj,tk::panedwindow) {s x*}
set {::syntax(_obj,tk::panedwindow cget)} o
set {::syntax(_obj,tk::panedwindow configure)} {o. x. p*}
set ::syntax(_obj,tk::radiobutton) {s x*}
set {::syntax(_obj,tk::radiobutton cget)} o
set {::syntax(_obj,tk::radiobutton configure)} {o. x. p*}
set ::syntax(_obj,tk::scale) {s x*}
set {::syntax(_obj,tk::scale cget)} o
set {::syntax(_obj,tk::scale configure)} {o. x. p*}
set ::syntax(_obj,tk::scrollbar) {s x*}
set {::syntax(_obj,tk::scrollbar cget)} o
set {::syntax(_obj,tk::scrollbar configure)} {o. x. p*}
set ::syntax(_obj,tk::spinbox) {s x*}
set {::syntax(_obj,tk::spinbox cget)} o
set {::syntax(_obj,tk::spinbox configure)} {o. x. p*}
set ::syntax(_obj,tk::text) {s x*}
set {::syntax(_obj,tk::text cget)} o
set {::syntax(_obj,tk::text configure)} {o. x. p*}
set ::syntax(_obj,tk::toplevel) {s x*}
set {::syntax(_obj,tk::toplevel cget)} o
set {::syntax(_obj,tk::toplevel configure)} {o. x. p*}
set ::syntax(_obj,toplevel) {s x*}
set {::syntax(_obj,toplevel cget)} o
set {::syntax(_obj,toplevel configure)} {o. x. p*}
set ::syntax(_obj,ttk::button) {s x*}
set {::syntax(_obj,ttk::button cget)} o
set {::syntax(_obj,ttk::button configure)} {o. x. p*}
set ::syntax(_obj,ttk::checkbutton) {s x*}
set {::syntax(_obj,ttk::checkbutton cget)} o
set {::syntax(_obj,ttk::checkbutton configure)} {o. x. p*}
set ::syntax(_obj,ttk::combobox) {s x*}
set {::syntax(_obj,ttk::combobox cget)} o
set {::syntax(_obj,ttk::combobox configure)} {o. x. p*}
set ::syntax(_obj,ttk::entry) {s x*}
set {::syntax(_obj,ttk::entry cget)} o
set {::syntax(_obj,ttk::entry configure)} {o. x. p*}
set ::syntax(_obj,ttk::frame) {s x*}
set {::syntax(_obj,ttk::frame cget)} o
set {::syntax(_obj,ttk::frame configure)} {o. x. p*}
set ::syntax(_obj,ttk::label) {s x*}
set {::syntax(_obj,ttk::label cget)} o
set {::syntax(_obj,ttk::label configure)} {o. x. p*}
set ::syntax(_obj,ttk::labelframe) {s x*}
set {::syntax(_obj,ttk::labelframe cget)} o
set {::syntax(_obj,ttk::labelframe configure)} {o. x. p*}
set ::syntax(_obj,ttk::menubutton) {s x*}
set {::syntax(_obj,ttk::menubutton cget)} o
set {::syntax(_obj,ttk::menubutton configure)} {o. x. p*}
set ::syntax(_obj,ttk::notebook) {s x*}
set {::syntax(_obj,ttk::notebook cget)} o
set {::syntax(_obj,ttk::notebook configure)} {o. x. p*}
set ::syntax(_obj,ttk::panedwindow) {s x*}
set {::syntax(_obj,ttk::panedwindow cget)} o
set {::syntax(_obj,ttk::panedwindow configure)} {o. x. p*}
set ::syntax(_obj,ttk::progressbar) {s x*}
set {::syntax(_obj,ttk::progressbar cget)} o
set {::syntax(_obj,ttk::progressbar configure)} {o. x. p*}
set ::syntax(_obj,ttk::radiobutton) {s x*}
set {::syntax(_obj,ttk::radiobutton cget)} o
set {::syntax(_obj,ttk::radiobutton configure)} {o. x. p*}
set ::syntax(_obj,ttk::scale) {s x*}
set {::syntax(_obj,ttk::scale cget)} o
set {::syntax(_obj,ttk::scale configure)} {o. x. p*}
set ::syntax(_obj,ttk::scrollbar) {s x*}
set {::syntax(_obj,ttk::scrollbar cget)} o
set {::syntax(_obj,ttk::scrollbar configure)} {o. x. p*}
set ::syntax(_obj,ttk::separator) {s x*}
set {::syntax(_obj,ttk::separator cget)} o
set {::syntax(_obj,ttk::separator configure)} {o. x. p*}
set ::syntax(_obj,ttk::sizegrip) {s x*}
set {::syntax(_obj,ttk::sizegrip cget)} o
set {::syntax(_obj,ttk::sizegrip configure)} {o. x. p*}
set ::syntax(_obj,ttk::treeview) {s x*}
set {::syntax(_obj,ttk::treeview cget)} o
set {::syntax(_obj,ttk::treeview configure)} {o. x. p*}
set ::syntax(_stdclass_oo) {s x*}
set {::syntax(_stdclass_oo create)} {dc=_obj,_stdclass_oo x?}
set {::syntax(_stdclass_oo destroy)} 0
set {::syntax(_stdclass_oo new)} 0
set {::syntax(_stdclass_oo variable)} n*
set {::syntax(_stdclass_oo varname)} v
set ::syntax(after) {r 1}
set ::syntax(append) {n x*}
set ::syntax(apply) {x x*}
set ::syntax(array) {s v x?}
set {::syntax(array default)} {s l x?}
set {::syntax(array default exists)} l=array
set {::syntax(array default get)} v=array
set {::syntax(array default set)} {v=array x}
set {::syntax(array default unset)} v=array
set {::syntax(array exists)} l=array
set {::syntax(array for)} {nl v=array c}
set {::syntax(array names)} {v=array x? x?}
set {::syntax(array set)} {n=array x}
set {::syntax(array size)} v=array
set {::syntax(array statistics)} v=array
set {::syntax(array unset)} {l x?}
set ::syntax(auto_execok) 1
set ::syntax(auto_import) 1
set ::syntax(auto_load) {r 1 2}
set ::syntax(auto_load_index) 0
set ::syntax(auto_mkindex) {r 1}
set ::syntax(auto_mkindex_old) {r 1}
set ::syntax(auto_mkindex_parser::childhook) 1
set ::syntax(auto_mkindex_parser::cleanup) 0
set ::syntax(auto_mkindex_parser::command) 3
set ::syntax(auto_mkindex_parser::commandInit) 3
set ::syntax(auto_mkindex_parser::fullname) 1
set ::syntax(auto_mkindex_parser::hook) 1
set ::syntax(auto_mkindex_parser::indexEntry) 1
set ::syntax(auto_mkindex_parser::init) 0
set ::syntax(auto_mkindex_parser::mkindex) 1
set ::syntax(auto_qualify) 2
set ::syntax(auto_reset) 0
set ::syntax(bell) {o* x*}
set ::syntax(bgerror) {r 1 2}
set ::syntax(binary) {s x*}
set {::syntax(binary decode)} {s x*}
set {::syntax(binary decode base64)} {o* x}
set {::syntax(binary decode hex)} {o* x}
set {::syntax(binary decode uuencode)} {o* x}
set {::syntax(binary encode)} {s x*}
set {::syntax(binary encode base64)} {p* x}
set {::syntax(binary encode hex)} x
set {::syntax(binary encode uuencode)} {p* x}
set {::syntax(binary scan)} {x x n n*}
set ::syntax(bind) {x x? cg?}
set ::syntax(bindtags) {x x?}
set ::syntax(break) 0
set ::syntax(button) {x p*}
set ::syntax(canvas) {x p*}
set ::syntax(catch) {c n? n?}
set ::syntax(cd) {r 0 1}
set ::syntax(chan) {s x*}
set {::syntax(chan blocked)} x
set {::syntax(chan close)} {x x?}
set {::syntax(chan configure)} {x o. x. p*}
set {::syntax(chan copy)} {x x p*}
set {::syntax(chan create)} {x x}
set {::syntax(chan eof)} x
set {::syntax(chan event)} {x x cg?}
set {::syntax(chan flush)} x
set {::syntax(chan gets)} {x n?}
set {::syntax(chan names)} x?
set {::syntax(chan pending)} {x x}
set {::syntax(chan pipe)} 0
set {::syntax(chan pop)} x
set {::syntax(chan postevent)} {x x}
set {::syntax(chan push)} {x c}
set {::syntax(chan puts)} {1: x : o? x x?}
set {::syntax(chan read)} {x x?}
set {::syntax(chan seek)} {r 2 3}
set {::syntax(chan tell)} 1
set {::syntax(chan truncate)} {x x?}
set ::syntax(checkbutton) {x p*}
set ::syntax(clipboard) {s x*}
set ::syntax(clock) {s x*}
set {::syntax(clock clicks)} o?
set {::syntax(clock format)} {x p*}
set {::syntax(clock scan)} {x p*}
set {::syntax(clock seconds)} 0
set ::syntax(close) {x x?}
set ::syntax(concat) {r 0}
set ::syntax(console) {r 1}
set ::syntax(continue) 0
set ::syntax(coroutine) {x x x*}
set ::syntax(destroy) x*
set ::syntax(dict) {s x x*}
set {::syntax(dict append)} {n x x*}
set {::syntax(dict create)} x&x*
set {::syntax(dict exists)} {x x x*}
set {::syntax(dict filter)} {x x x*}
set {::syntax(dict filter key)} x*
set {::syntax(dict filter script)} {nl c}
set {::syntax(dict filter value)} x*
set {::syntax(dict for)} {nl x c}
set {::syntax(dict incr)} {n x x*}
set {::syntax(dict info)} x
set {::syntax(dict keys)} {x x?}
set {::syntax(dict lappend)} {n x x*}
set {::syntax(dict map)} {nl x c}
set {::syntax(dict remove)} {x x*}
set {::syntax(dict replace)} {x x*}
set {::syntax(dict set)} {n x x x*}
set {::syntax(dict size)} x
set {::syntax(dict unset)} {n x x*}
set {::syntax(dict update)} {l x n x&n* c}
set {::syntax(dict values)} {x x?}
set {::syntax(dict with)} {n x* c}
set ::syntax(encoding) {s x*}
set {::syntax(encoding convertfrom)} {p? p? x? x}
set {::syntax(encoding convertto)} {p? p? x? x}
set {::syntax(encoding names)} 0
set {::syntax(encoding system)} {r 0 1}
set ::syntax(entry) {x p*}
set ::syntax(eof) 1
set ::syntax(error) {r 1 3}
set ::syntax(event) {s x*}
set ::syntax(exec) {o* x x*}
set ::syntax(exit) {r 0 1}
set ::syntax(fblocked) 1
set ::syntax(fconfigure) {x o. x. p*}
set ::syntax(fcopy) {x x p*}
set ::syntax(file) {s x*}
set {::syntax(file atime)} {x x?}
set {::syntax(file attributes)} {x o. x. p*}
set {::syntax(file channels)} x?
set {::syntax(file copy)} {o* x x x*}
set {::syntax(file delete)} {o* x*}
set {::syntax(file dirname)} x
set {::syntax(file executable)} x
set {::syntax(file exists)} x
set {::syntax(file extension)} x
set {::syntax(file home)} x?
set {::syntax(file isdirectory)} x
set {::syntax(file isfile)} x
set {::syntax(file join)} {x x*}
set {::syntax(file link)} {o? x x?}
set {::syntax(file lstat)} {x n}
set {::syntax(file mkdir)} x*
set {::syntax(file mtime)} {x x?}
set {::syntax(file nativename)} x
set {::syntax(file normalize)} x
set {::syntax(file owned)} x
set {::syntax(file pathtype)} x
set {::syntax(file readable)} x
set {::syntax(file readlink)} x
set {::syntax(file rename)} {o* x x x*}
set {::syntax(file rootname)} x
set {::syntax(file separator)} x?
set {::syntax(file size)} x
set {::syntax(file split)} x
set {::syntax(file stat)} {x n}
set {::syntax(file system)} x
set {::syntax(file tail)} x
set {::syntax(file tempfile)} {n? x?}
set {::syntax(file tildeexpand)} x
set {::syntax(file type)} x
set {::syntax(file volumes)} 0
set {::syntax(file writable)} x
set ::syntax(fileevent) {x x x?}
set ::syntax(flush) 1
set ::syntax(focus) {o? x?}
set ::syntax(font) {s x*}
set ::syntax(for) {c E c c}
set ::syntax(format) {r 1}
set ::syntax(frame) {x p*}
set ::syntax(gets) {x n?}
set ::syntax(glob) {o* x*}
set ::syntax(grab) {x x*}
set ::syntax(grid) {x x*}
set ::syntax(history) {s x*}
set ::syntax(if) {e c}
set ::syntax(image) {s x*}
set ::syntax(incr) {n x?}
set ::syntax(info) {s x*}
set {::syntax(info class)} {s x x*}
set {::syntax(info cmdtype)} x
set {::syntax(info coroutine)} 0
set {::syntax(info default)} {x x n}
set {::syntax(info exists)} l
set {::syntax(info object)} {s x x*}
set ::syntax(interp) {s x*}
set {::syntax(interp cancel)} {o* x? x?}
set {::syntax(interp invokehidden)} {x o* x x*}
set ::syntax(join) {r 1 2}
set ::syntax(label) {x p*}
set ::syntax(labelframe) {x p*}
set ::syntax(lappend) {n x*}
set ::syntax(lassign) {x n*}
set ::syntax(ledit) {v x x x*}
set ::syntax(lindex) {r 1}
set ::syntax(linsert) {r 2}
set ::syntax(list) {r 0}
set ::syntax(listbox) {x p*}
set ::syntax(llength) 1
set ::syntax(lmap) {n x c}
set ::syntax(load) {r 1 3}
set ::syntax(lower) {x x?}
set ::syntax(lpop) {v x*}
set ::syntax(lrange) 3
set ::syntax(lrepeat) {r 1}
set ::syntax(lreplace) {r 3}
set ::syntax(lreverse) 1
set ::syntax(lsearch) {o* x x}
set ::syntax(lseq) {x x*}
set ::syntax(lset) {n x x x*}
set ::syntax(lsort) {o* x}
set ::syntax(menu) {x p*}
set ::syntax(menubutton) {x p*}
set ::syntax(message) {x p*}
set ::syntax(msgcat::mc) {r 0}
set ::syntax(msgcat::mcexists) {r 0}
set ::syntax(msgcat::mcflmset) 1
set ::syntax(msgcat::mcflset) {r 1 2}
set ::syntax(msgcat::mcforgetpackage) 0
set ::syntax(msgcat::mcload) 1
set ::syntax(msgcat::mcloadedlocales) 1
set ::syntax(msgcat::mclocale) {r 0}
set ::syntax(msgcat::mcmax) {r 0}
set ::syntax(msgcat::mcmset) 2
set ::syntax(msgcat::mcn) {r 2}
set ::syntax(msgcat::mcpackageconfig) {r 2 3}
set ::syntax(msgcat::mcpackagelocale) {r 1}
set ::syntax(msgcat::mcpackagenamespaceget) 0
set ::syntax(msgcat::mcpreferences) {r 0}
set ::syntax(msgcat::mcset) {r 2 3}
set ::syntax(msgcat::mcunknown) {r 0}
set ::syntax(msgcat::mcutil::getpreferences) 1
set ::syntax(msgcat::mcutil::getsystemlocale) 0
set ::syntax(my) {s x*}
set {::syntax(my variable)} n*
set ::syntax(namespace) {s x*}
set {::syntax(namespace code)} c
set {::syntax(namespace import)} {o* x*}
set {::syntax(namespace which)} {o* x?}
set ::syntax(oo::class) {s x*}
set {::syntax(oo::class create)} {do=_stdclass_oo cn?}
set {::syntax(oo::class create::class)} x
set {::syntax(oo::class create::constructor)} dk
set {::syntax(oo::class create::deletemethod)} {x x*}
set {::syntax(oo::class create::destructor)} dd
set {::syntax(oo::class create::export)} {x x*}
set {::syntax(oo::class create::filter)} {o? x*}
set {::syntax(oo::class create::forward)} {x x x*}
set {::syntax(oo::class create::method)} dm
set {::syntax(oo::class create::mixin)} {o? di}
set {::syntax(oo::class create::renamemethod)} {x x}
set {::syntax(oo::class create::self)} x*
set {::syntax(oo::class create::superclass)} {o? di}
set {::syntax(oo::class create::unexport)} {x x*}
set {::syntax(oo::class create::variable)} {o? div*}
set ::syntax(oo::copy) {x x?}
set ::syntax(oo::define) {2: do cn : do s x x*}
set {::syntax(oo::define class)} x
set {::syntax(oo::define constructor)} dk
set {::syntax(oo::define deletemethod)} {x x*}
set {::syntax(oo::define destructor)} dd
set {::syntax(oo::define export)} {x x*}
set {::syntax(oo::define filter)} {o? x*}
set {::syntax(oo::define forward)} {x x x*}
set {::syntax(oo::define method)} dm
set {::syntax(oo::define mixin)} {o? di}
set {::syntax(oo::define renamemethod)} {x x}
set {::syntax(oo::define self)} x*
set {::syntax(oo::define superclass)} {o? di}
set {::syntax(oo::define unexport)} {x x*}
set {::syntax(oo::define variable)} {o? div*}
set ::syntax(oo::define::class) x
set ::syntax(oo::define::constructor) dk
set ::syntax(oo::define::deletemethod) {x x*}
set ::syntax(oo::define::destructor) dd
set ::syntax(oo::define::export) {x x*}
set ::syntax(oo::define::filter) {o? x*}
set ::syntax(oo::define::forward) {x x x*}
set ::syntax(oo::define::method) dm
set ::syntax(oo::define::mixin) {o? di}
set ::syntax(oo::define::renamemethod) {x x}
set ::syntax(oo::define::self) x*
set ::syntax(oo::define::superclass) {o? di}
set ::syntax(oo::define::unexport) {x x*}
set ::syntax(oo::define::variable) {o? div*}
set ::syntax(oo::objdefine) {2: do cn : do s x x*}
set {::syntax(oo::objdefine class)} x
set {::syntax(oo::objdefine constructor)} dk
set {::syntax(oo::objdefine deletemethod)} {x x*}
set {::syntax(oo::objdefine destructor)} dd
set {::syntax(oo::objdefine export)} {x x*}
set {::syntax(oo::objdefine filter)} {o? x*}
set {::syntax(oo::objdefine forward)} {x x x*}
set {::syntax(oo::objdefine method)} dm
set {::syntax(oo::objdefine mixin)} {o? di}
set {::syntax(oo::objdefine renamemethod)} {x x}
set {::syntax(oo::objdefine self)} x*
set {::syntax(oo::objdefine superclass)} {o? di}
set {::syntax(oo::objdefine unexport)} {x x*}
set {::syntax(oo::objdefine variable)} {o? div*}
set ::syntax(oo::objdefine::class) x
set ::syntax(oo::objdefine::constructor) dk
set ::syntax(oo::objdefine::deletemethod) {x x*}
set ::syntax(oo::objdefine::destructor) dd
set ::syntax(oo::objdefine::export) {x x*}
set ::syntax(oo::objdefine::filter) {o? x*}
set ::syntax(oo::objdefine::forward) {x x x*}
set ::syntax(oo::objdefine::method) dm
set ::syntax(oo::objdefine::mixin) {o? di}
set ::syntax(oo::objdefine::renamemethod) {x x}
set ::syntax(oo::objdefine::self) x*
set ::syntax(oo::objdefine::superclass) {o? di}
set ::syntax(oo::objdefine::unexport) {x x*}
set ::syntax(oo::objdefine::variable) {o? div*}
set ::syntax(oo::object) {s x*}
set ::syntax(open) {r 1 3}
set ::syntax(option) {s x*}
set ::syntax(pack) {x x*}
set ::syntax(package) {s x*}
set {::syntax(package require)} {o* x x*}
set ::syntax(panedwindow) {x p*}
set ::syntax(parray) {v x?}
set ::syntax(pid) {r 0 1}
set ::syntax(pkg_mkIndex) {r 0}
set ::syntax(place) {x x*}
set ::syntax(proc) dp
set ::syntax(puts) {1: x : o? x x?}
set ::syntax(pwd) 0
set ::syntax(radiobutton) {x p*}
set ::syntax(raise) {x x?}
set ::syntax(read) {r 1 2}
set ::syntax(regexp) {o* re x n*}
set ::syntax(regsub) {o* re x x n?}
set ::syntax(rename) 2
set ::syntax(return) {p* x?}
set ::syntax(safe::interpAddToAccessPath) 2
set ::syntax(safe::interpConfigure) {r 0}
set ::syntax(safe::interpCreate) {r 0}
set ::syntax(safe::interpDelete) 1
set ::syntax(safe::interpFindInAccessPath) 2
set ::syntax(safe::interpInit) {r 0}
set ::syntax(safe::setLogCmd) {r 0}
set ::syntax(scale) {x p*}
set ::syntax(scan) {x x n*}
set ::syntax(scrollbar) {x p*}
set ::syntax(seek) {r 2 3}
set ::syntax(selection) {s x*}
set ::syntax(self) s
set ::syntax(send) {o* x x x*}
set ::syntax(set) {1: v=scalar : n=scalar x}
set ::syntax(socket) {r 2}
set ::syntax(source) {p* x}
set ::syntax(spinbox) {x p*}
set ::syntax(split) {r 1 2}
set ::syntax(string) {s x x*}
set {::syntax(string bytelength)} 1
set {::syntax(string compare)} {o* x x}
set {::syntax(string equal)} {o* x x}
set {::syntax(string first)} {r 2 3}
set {::syntax(string index)} 2
set {::syntax(string is)} {s o* x}
set {::syntax(string last)} {r 2 3}
set {::syntax(string length)} 1
set {::syntax(string map)} {o? x x}
set {::syntax(string match)} {o? x x}
set {::syntax(string range)} 3
set {::syntax(string repeat)} 2
set {::syntax(string replace)} {r 3 4}
set {::syntax(string reverse)} 1
set {::syntax(string tolower)} {r 1 3}
set {::syntax(string totitle)} {r 1 3}
set {::syntax(string toupper)} {r 1 3}
set {::syntax(string trim)} {r 1 2}
set {::syntax(string trimleft)} {r 1 2}
set {::syntax(string trimright)} {r 1 2}
set {::syntax(string wordend)} 2
set {::syntax(string wordstart)} 2
set ::syntax(subst) {o* x}
set ::syntax(switch) x*
set ::syntax(tcl::Lassign) {r 1}
set ::syntax(tcl::Lempty) 1
set ::syntax(tcl::Lget) 2
set ::syntax(tcl::Lvarincr) {r 2 3}
set ::syntax(tcl::Lvarpop) 1
set ::syntax(tcl::Lvarpop1) 1
set ::syntax(tcl::Lvarset) 3
set ::syntax(tcl::OptKeyDelete) 1
set ::syntax(tcl::OptKeyError) {r 2 3}
set ::syntax(tcl::OptKeyParse) 2
set ::syntax(tcl::OptKeyRegister) {r 1 2}
set ::syntax(tcl::OptParse) 2
set ::syntax(tcl::OptProc) 3
set ::syntax(tcl::OptProcArgGiven) 1
set ::syntax(tcl::Pkg::source) 1
set ::syntax(tcl::SetMax) 2
set ::syntax(tcl::SetMin) 2
set ::syntax(tcl::clock::add) {r 1}
set ::syntax(tcl::clock::format) {r 0}
set ::syntax(tcl::clock::scan) {r 0}
set ::syntax(tcl::mathfunc::abs) 1
set ::syntax(tcl::mathfunc::acos) 1
set ::syntax(tcl::mathfunc::asin) 1
set ::syntax(tcl::mathfunc::atan) 1
set ::syntax(tcl::mathfunc::atan2) 2
set ::syntax(tcl::mathfunc::bool) 1
set ::syntax(tcl::mathfunc::ceil) 1
set ::syntax(tcl::mathfunc::cos) 1
set ::syntax(tcl::mathfunc::cosh) 1
set ::syntax(tcl::mathfunc::double) 1
set ::syntax(tcl::mathfunc::entier) 1
set ::syntax(tcl::mathfunc::exp) 1
set ::syntax(tcl::mathfunc::floor) 1
set ::syntax(tcl::mathfunc::fmod) 2
set ::syntax(tcl::mathfunc::hypot) 2
set ::syntax(tcl::mathfunc::int) 1
set ::syntax(tcl::mathfunc::isfinite) 1
set ::syntax(tcl::mathfunc::isinf) 1
set ::syntax(tcl::mathfunc::isnan) 1
set ::syntax(tcl::mathfunc::isnormal) 1
set ::syntax(tcl::mathfunc::isqrt) 1
set ::syntax(tcl::mathfunc::issubnormal) 1
set ::syntax(tcl::mathfunc::isunordered) 2
set ::syntax(tcl::mathfunc::log) 1
set ::syntax(tcl::mathfunc::log10) 1
set ::syntax(tcl::mathfunc::max) {r 1}
set ::syntax(tcl::mathfunc::min) {r 1}
set ::syntax(tcl::mathfunc::pow) 2
set ::syntax(tcl::mathfunc::rand) 0
set ::syntax(tcl::mathfunc::round) 1
set ::syntax(tcl::mathfunc::sin) 1
set ::syntax(tcl::mathfunc::sinh) 1
set ::syntax(tcl::mathfunc::sqrt) 1
set ::syntax(tcl::mathfunc::srand) 1
set ::syntax(tcl::mathfunc::tan) 1
set ::syntax(tcl::mathfunc::tanh) 1
set ::syntax(tcl::mathfunc::wide) 1
set ::syntax(tcl::mathop::!) 1
set ::syntax(tcl::mathop::!=) 2
set ::syntax(tcl::mathop::%) 2
set ::syntax(tcl::mathop::&) {r 0}
set ::syntax(tcl::mathop::*) {r 0}
set ::syntax(tcl::mathop::**) {r 0}
set ::syntax(tcl::mathop::+) {r 0}
set ::syntax(tcl::mathop::-) {r 1}
set ::syntax(tcl::mathop::/) {r 1}
set ::syntax(tcl::mathop::<) {r 0}
set ::syntax(tcl::mathop::<<) 2
set ::syntax(tcl::mathop::<=) {r 0}
set ::syntax(tcl::mathop::==) {r 0}
set ::syntax(tcl::mathop::>) {r 0}
set ::syntax(tcl::mathop::>=) {r 0}
set ::syntax(tcl::mathop::>>) 2
set ::syntax(tcl::mathop::^) {r 0}
set ::syntax(tcl::mathop::eq) {r 0}
set ::syntax(tcl::mathop::ge) {r 0}
set ::syntax(tcl::mathop::gt) {r 0}
set ::syntax(tcl::mathop::in) 2
set ::syntax(tcl::mathop::le) {r 0}
set ::syntax(tcl::mathop::lt) {r 0}
set ::syntax(tcl::mathop::ne) 2
set ::syntax(tcl::mathop::ni) 2
set ::syntax(tcl::mathop::|) {r 0}
set ::syntax(tcl::mathop::~) 1
set ::syntax(tcl::prefix) {s x*}
set {::syntax(tcl::prefix all)} {x x}
set {::syntax(tcl::prefix longest)} {x x}
set {::syntax(tcl::prefix match)} {o* x x}
set ::syntax(tcl::process) {s x*}
set {::syntax(tcl::process autoperge)} x?
set {::syntax(tcl::process list)} 0
set {::syntax(tcl::process purge)} x?
set {::syntax(tcl::process status)} {o* x?}
set ::syntax(tcl::zipfs::find) 1
set ::syntax(tclListValidFlags) 1
set ::syntax(tclLog) 1
set ::syntax(tclParseConfigSpec) 4
set ::syntax(tclPkgSetup) 4
set ::syntax(tclPkgUnknown) {r 1}
set ::syntax(tcl_endOfWord) 2
set ::syntax(tcl_findLibrary) 6
set ::syntax(tcl_startOfNextWord) 2
set ::syntax(tcl_startOfPreviousWord) 2
set ::syntax(tcl_wordBreakAfter) 2
set ::syntax(tcl_wordBreakBefore) 2
set ::syntax(tell) 1
set ::syntax(text) {x p*}
set ::syntax(throw) 2
set ::syntax(time) {c x?}
set ::syntax(timerate) {o* c x? x?}
set ::syntax(tk) {s x*}
set ::syntax(tk::ScaleNum) 1
set ::syntax(tk::ScalingPct) 0
set ::syntax(tk::button) {x p*}
set ::syntax(tk::canvas) {x p*}
set ::syntax(tk::checkbutton) {x p*}
set ::syntax(tk::classic::restore) {r 0}
set ::syntax(tk::classic::restore_button) {r 0}
set ::syntax(tk::classic::restore_entry) {r 0}
set ::syntax(tk::classic::restore_font) {r 0}
set ::syntax(tk::classic::restore_listbox) {r 0}
set ::syntax(tk::classic::restore_menu) {r 0}
set ::syntax(tk::classic::restore_menubutton) {r 0}
set ::syntax(tk::classic::restore_message) {r 0}
set ::syntax(tk::classic::restore_panedwindow) {r 0}
set ::syntax(tk::classic::restore_scale) {r 0}
set ::syntax(tk::classic::restore_scrollbar) {r 0}
set ::syntax(tk::classic::restore_text) {r 0}
set ::syntax(tk::dialog::color::mc) {r 0}
set ::syntax(tk::dialog::color::mcmax) {r 0}
set ::syntax(tk::dialog::error::bgerror) {r 1 2}
set ::syntax(tk::dialog::file::chooseDir::mc) {r 0}
set ::syntax(tk::dialog::file::chooseDir::mcmax) {r 0}
set ::syntax(tk::dialog::file::mc) {r 0}
set ::syntax(tk::dialog::file::mcmax) {r 0}
set ::syntax(tk::entry) {x p*}
set ::syntax(tk::fontchooser::ttk_slistbox) {r 1}
set ::syntax(tk::frame) {x p*}
set ::syntax(tk::label) {x p*}
set ::syntax(tk::labelframe) {x p*}
set ::syntax(tk::listbox) {x p*}
set ::syntax(tk::menubutton) {x p*}
set ::syntax(tk::message) {x p*}
set ::syntax(tk::msgcat::mc) {r 0}
set ::syntax(tk::msgcat::mcmax) {r 0}
set ::syntax(tk::panedwindow) {x p*}
set ::syntax(tk::ps::function) 2
set ::syntax(tk::ps::literal) 1
set ::syntax(tk::ps::variable) 2
set ::syntax(tk::radiobutton) {x p*}
set ::syntax(tk::scale) {x p*}
set ::syntax(tk::scrollbar) {x p*}
set ::syntax(tk::spinbox) {x p*}
set ::syntax(tk::sysnotify::sysnotify) 2
set ::syntax(tk::systray::configure) {r 0}
set ::syntax(tk::systray::create) {r 0}
set ::syntax(tk::systray::destroy) 0
set ::syntax(tk::systray::exists) 0
set ::syntax(tk::text) {x p*}
set ::syntax(tk::toplevel) {x p*}
set ::syntax(tk_bindForTraversal) {r 0}
set ::syntax(tk_bisque) 0
set ::syntax(tk_chooseColor) p*
set ::syntax(tk_chooseDirectory) p*
set ::syntax(tk_dialog) {r 5}
set ::syntax(tk_focusFollowsMouse) 0
set ::syntax(tk_focusNext) 1
set ::syntax(tk_focusPrev) 1
set ::syntax(tk_getOpenFile) p*
set ::syntax(tk_getSaveFile) p*
set ::syntax(tk_menuBar) {r 0}
set ::syntax(tk_menuSetFocus) 1
set ::syntax(tk_messageBox) p*
set ::syntax(tk_optionMenu) {r 3}
set ::syntax(tk_popup) {r 3 4}
set ::syntax(tk_setPalette) {r 0}
set ::syntax(tk_textCopy) 1
set ::syntax(tk_textCut) 1
set ::syntax(tk_textPaste) 1
set ::syntax(tkwait) {s x}
set {::syntax(tkwait variable)} l
set ::syntax(toplevel) {x p*}
set ::syntax(trace) {s x x*}
set {::syntax(trace add)} {s x x x}
set {::syntax(trace add command)} {x x c3}
set {::syntax(trace add execution)} {x s c2}
set {::syntax(trace add execution leave)} c4
set {::syntax(trace add execution leavestep)} c4
set {::syntax(trace add variable)} {v x c3}
set {::syntax(trace info)} {s x x x}
set {::syntax(trace info command)} x
set {::syntax(trace info execution)} x
set {::syntax(trace info variable)} v
set {::syntax(trace remove)} {s x x x}
set {::syntax(trace remove command)} {x x x}
set {::syntax(trace remove execution)} {x x x}
set {::syntax(trace remove variable)} {v x x}
set {::syntax(trace variable)} {n x x}
set {::syntax(trace vdelete)} {v x x}
set {::syntax(trace vinfo)} l
set ::syntax(try) {c x*}
set ::syntax(ttk::button) {x p*}
set ::syntax(ttk::button::activate) 1
set ::syntax(ttk::checkbutton) {x p*}
set ::syntax(ttk::combobox) {x p*}
set ::syntax(ttk::entry) {x p*}
set ::syntax(ttk::frame) {x p*}
set ::syntax(ttk::label) {x p*}
set ::syntax(ttk::labelframe) {x p*}
set ::syntax(ttk::menubutton) {x p*}
set ::syntax(ttk::notebook) {x p*}
set ::syntax(ttk::notebook::enableTraversal) 1
set ::syntax(ttk::panedwindow) {x p*}
set ::syntax(ttk::progressbar) {x p*}
set ::syntax(ttk::progressbar::start) {r 1 3}
set ::syntax(ttk::progressbar::stop) 1
set ::syntax(ttk::radiobutton) {x p*}
set ::syntax(ttk::scale) {x p*}
set ::syntax(ttk::scrollbar) {x p*}
set ::syntax(ttk::separator) {x p*}
set ::syntax(ttk::setTheme) x
set ::syntax(ttk::sizegrip) {x p*}
set ::syntax(ttk::style) {s x*}
set {::syntax(ttk::style configure)} {x o. x. p*}
set {::syntax(ttk::style element)} {s x*}
set {::syntax(ttk::style element create)} {x x x*}
set {::syntax(ttk::style element names)} 0
set {::syntax(ttk::style element options)} x
set {::syntax(ttk::style layout)} {x x?}
set {::syntax(ttk::style lookup)} {r 2 4}
set {::syntax(ttk::style map)} {x p*}
set {::syntax(ttk::style theme)} {s x*}
set {::syntax(ttk::style theme create)} {x p*}
set {::syntax(ttk::style theme names)} 0
set {::syntax(ttk::style theme settings)} {x c}
set {::syntax(ttk::style theme use)} x
set ::syntax(ttk::theme::default::reconfigureDefaultTheme) 0
set ::syntax(ttk::themes) x?
set ::syntax(ttk::treeview) {x p*}
set ::syntax(ttk::treeview::between) 3
set ::syntax(ttk::treeview::heading.drag) 3
set ::syntax(ttk::treeview::heading.press) 3
set ::syntax(ttk::treeview::heading.release) 1
set ::syntax(ttk::treeview::resize.drag) 2
set ::syntax(ttk::treeview::resize.press) 3
set ::syntax(ttk::treeview::resize.release) 2
set ::syntax(ttk::treeview::select.choose.browse) 3
set ::syntax(ttk::treeview::select.choose.extended) 3
set ::syntax(ttk::treeview::select.choose.none) 3
set ::syntax(ttk::treeview::select.extend.browse) 3
set ::syntax(ttk::treeview::select.extend.extended) 3
set ::syntax(ttk::treeview::select.extend.none) 3
set ::syntax(ttk::treeview::select.toggle.browse) 3
set ::syntax(ttk::treeview::select.toggle.extended) 3
set ::syntax(ttk::treeview::select.toggle.none) 3
set ::syntax(unknown) {r 0}
set ::syntax(unload) {o* x x*}
set ::syntax(unset) {o* l l*}
set ::syntax(update) s.
set ::syntax(vwait) n
set ::syntax(while) {E c}
set ::syntax(winfo) {s x x*}
set ::syntax(wm) {s x x*}
set ::syntax(yield) x?
set ::syntax(yieldto) {x x*}
set ::syntax(zipfs) {s x*}
set {::syntax(zipfs canonical)} {r 1 3}
set {::syntax(zipfs exists)} 1
set {::syntax(zipfs find)} 1
set {::syntax(zipfs info)} 1
set {::syntax(zipfs list)} {o* x?}
set {::syntax(zipfs lmkimg)} {r 2 4}
set {::syntax(zipfs lmkzip)} {r 2 3}
set {::syntax(zipfs mkimg)} {r 2 5}
set {::syntax(zipfs mkkey)} 1
set {::syntax(zipfs mkzip)} {r 2 4}
set {::syntax(zipfs mount)} {r 0 3}
set {::syntax(zipfs root)} 0
set {::syntax(zipfs unmount)} 1
set ::syntax(zlib) {s x*}
set {::syntax(zlib adler32)} {x x?}
set {::syntax(zlib compress)} {x x?}
set {::syntax(zlib crc32)} {x x?}
set {::syntax(zlib decompress)} {x x?}
set {::syntax(zlib deflate)} {x x?}
set {::syntax(zlib gunzip)} {x p*}
set {::syntax(zlib gzip)} {x p*}
set {::syntax(zlib inflate)} {x x?}
set {::syntax(zlib push)} {s x p*}
set {::syntax(zlib stream)} {s x*}
set {::syntax(zlib stream compress)} p*
set {::syntax(zlib stream decompress)} p*
set {::syntax(zlib stream deflate)} p*
set {::syntax(zlib stream gunzip)} 0
set {::syntax(zlib stream gzip)} p*
set {::syntax(zlib stream inflate)} p*

set {::return(_stdclass_oo create)} _obj,_stdclass_oo
set {::return(_stdclass_oo new)} _obj,_stdclass_oo
set {::return(_stdclass_oo varname)} varName
set ::return(button) _obj,button
set ::return(canvas) _obj,canvas
set ::return(checkbutton) _obj,checkbutton
set ::return(entry) _obj,entry
set ::return(frame) _obj,frame
set ::return(label) _obj,label
set ::return(labelframe) _obj,labelframe
set ::return(linsert) list
set ::return(list) list
set ::return(listbox) _obj,listbox
set ::return(llength) int
set ::return(lrange) list
set ::return(lreplace) list
set ::return(lsort) list
set ::return(menu) _obj,menu
set ::return(menubutton) _obj,menubutton
set ::return(message) _obj,message
set {::return(namespace code)} script
set ::return(panedwindow) _obj,panedwindow
set ::return(radiobutton) _obj,radiobutton
set ::return(scale) _obj,scale
set ::return(scrollbar) _obj,scrollbar
set ::return(spinbox) _obj,spinbox
set ::return(text) _obj,text
set ::return(tk::button) _obj,tk::button
set ::return(tk::canvas) _obj,tk::canvas
set ::return(tk::checkbutton) _obj,tk::checkbutton
set ::return(tk::entry) _obj,tk::entry
set ::return(tk::frame) _obj,tk::frame
set ::return(tk::label) _obj,tk::label
set ::return(tk::labelframe) _obj,tk::labelframe
set ::return(tk::listbox) _obj,tk::listbox
set ::return(tk::menubutton) _obj,tk::menubutton
set ::return(tk::message) _obj,tk::message
set ::return(tk::panedwindow) _obj,tk::panedwindow
set ::return(tk::radiobutton) _obj,tk::radiobutton
set ::return(tk::scale) _obj,tk::scale
set ::return(tk::scrollbar) _obj,tk::scrollbar
set ::return(tk::spinbox) _obj,tk::spinbox
set ::return(tk::text) _obj,tk::text
set ::return(tk::toplevel) _obj,tk::toplevel
set ::return(toplevel) _obj,toplevel
set ::return(ttk::button) _obj,ttk::button
set ::return(ttk::checkbutton) _obj,ttk::checkbutton
set ::return(ttk::combobox) _obj,ttk::combobox
set ::return(ttk::entry) _obj,ttk::entry
set ::return(ttk::frame) _obj,ttk::frame
set ::return(ttk::label) _obj,ttk::label
set ::return(ttk::labelframe) _obj,ttk::labelframe
set ::return(ttk::menubutton) _obj,ttk::menubutton
set ::return(ttk::notebook) _obj,ttk::notebook
set ::return(ttk::panedwindow) _obj,ttk::panedwindow
set ::return(ttk::progressbar) _obj,ttk::progressbar
set ::return(ttk::radiobutton) _obj,ttk::radiobutton
set ::return(ttk::scale) _obj,ttk::scale
set ::return(ttk::scrollbar) _obj,ttk::scrollbar
set ::return(ttk::separator) _obj,ttk::separator
set ::return(ttk::sizegrip) _obj,ttk::sizegrip
set ::return(ttk::treeview) _obj,ttk::treeview

set ::subCmd(.) {cget configure}
set ::subCmd(_obj,button) {cget configure flash invoke}
set ::subCmd(_obj,canvas) {addtag bbox bind canvasx canvasy cget configure coords create dchars delete dtag find focus gettags icursor image imove index insert itemcget itemconfigure lower move moveto postscript raise rchars rotate scale scan select type xview yview}
set ::subCmd(_obj,checkbutton) {cget configure deselect flash invoke select toggle}
set ::subCmd(_obj,entry) {bbox cget configure delete get icursor index insert scan selection validate xview}
set ::subCmd(_obj,frame) {cget configure}
set ::subCmd(_obj,label) {cget configure}
set ::subCmd(_obj,labelframe) {cget configure}
set ::subCmd(_obj,listbox) {activate bbox cget configure curselection delete get index insert itemcget itemconfigure nearest scan see selection size xview yview}
set {::subCmd(_obj,listbox selection)} {anchor clear includes set}
set ::subCmd(_obj,menu) {activate add cget clone configure delete entrycget entryconfigure id index insert invoke post postcascade type unpost xposition yposition}
set ::subCmd(_obj,menubutton) {cget configure}
set ::subCmd(_obj,message) {cget configure}
set ::subCmd(_obj,panedwindow) {add cget configure forget identify panecget paneconfigure panes proxy sash}
set ::subCmd(_obj,radiobutton) {cget configure deselect flash invoke select}
set ::subCmd(_obj,scale) {cget configure coords get identify set}
set ::subCmd(_obj,scrollbar) {activate cget configure delta fraction get identify set}
set ::subCmd(_obj,spinbox) {bbox cget configure delete get icursor identify index insert invoke scan selection set validate xview}
set ::subCmd(_obj,text) {bbox cget compare configure count debug delete dlineinfo dump edit get image index insert mark peer pendingsync replace scan search see sync tag window xview yview}
set {::subCmd(_obj,text edit)} {canredo canundo modified redo reset separator undo}
set {::subCmd(_obj,text image)} {cget configure create names}
set {::subCmd(_obj,text mark)} {gravity names next previous set unset}
set {::subCmd(_obj,text peer)} {create names}
set {::subCmd(_obj,text tag)} {add bind cget configure delete lower names nextrange prevrange raise ranges remove}
set {::subCmd(_obj,text window)} {cget configure create names}
set {::subCmd(_obj,text xview)} {moveto scroll}
set ::subCmd(_obj,tk::button) {cget configure flash invoke}
set ::subCmd(_obj,tk::canvas) {addtag bbox bind canvasx canvasy cget configure coords create dchars delete dtag find focus gettags icursor image imove index insert itemcget itemconfigure lower move moveto postscript raise rchars rotate scale scan select type xview yview}
set ::subCmd(_obj,tk::checkbutton) {cget configure deselect flash invoke select toggle}
set ::subCmd(_obj,tk::entry) {bbox cget configure delete get icursor index insert scan selection validate xview}
set ::subCmd(_obj,tk::frame) {cget configure}
set ::subCmd(_obj,tk::label) {cget configure}
set ::subCmd(_obj,tk::labelframe) {cget configure}
set ::subCmd(_obj,tk::listbox) {activate bbox cget configure curselection delete get index insert itemcget itemconfigure nearest scan see selection size xview yview}
set ::subCmd(_obj,tk::menubutton) {cget configure}
set ::subCmd(_obj,tk::message) {cget configure}
set ::subCmd(_obj,tk::panedwindow) {add cget configure forget identify panecget paneconfigure panes proxy sash}
set ::subCmd(_obj,tk::radiobutton) {cget configure deselect flash invoke select}
set ::subCmd(_obj,tk::scale) {cget configure coords get identify set}
set ::subCmd(_obj,tk::scrollbar) {activate cget configure delta fraction get identify set}
set ::subCmd(_obj,tk::spinbox) {bbox cget configure delete get icursor identify index insert invoke scan selection set validate xview}
set ::subCmd(_obj,tk::text) {bbox cget compare configure count debug delete dlineinfo dump edit get image index insert mark peer pendingsync replace scan search see sync tag window xview yview}
set ::subCmd(_obj,tk::toplevel) {cget configure}
set ::subCmd(_obj,toplevel) {cget configure}
set ::subCmd(_obj,ttk::button) {cget configure identify instate invoke state style}
set ::subCmd(_obj,ttk::checkbutton) {cget configure identify instate invoke state style}
set ::subCmd(_obj,ttk::combobox) {bbox cget configure current delete get icursor identify index insert instate selection set state style validate xview}
set ::subCmd(_obj,ttk::entry) {bbox cget configure delete get icursor identify index insert instate selection state style validate xview}
set ::subCmd(_obj,ttk::frame) {cget configure identify instate state style}
set ::subCmd(_obj,ttk::label) {cget configure identify instate state style}
set ::subCmd(_obj,ttk::labelframe) {cget configure identify instate state style}
set ::subCmd(_obj,ttk::menubutton) {cget configure identify instate state style}
set ::subCmd(_obj,ttk::notebook) {add cget configure forget hide identify index insert instate select state style tab tabs}
set ::subCmd(_obj,ttk::panedwindow) {add cget configure forget identify insert instate pane panes sashpos state style}
set ::subCmd(_obj,ttk::progressbar) {cget configure identify instate start state step stop style}
set ::subCmd(_obj,ttk::radiobutton) {cget configure identify instate invoke state style}
set ::subCmd(_obj,ttk::scale) {cget configure coords get identify instate set state style}
set ::subCmd(_obj,ttk::scrollbar) {cget configure delta fraction get identify instate set state style}
set ::subCmd(_obj,ttk::separator) {cget configure identify instate state style}
set ::subCmd(_obj,ttk::sizegrip) {cget configure identify instate state style}
set ::subCmd(_obj,ttk::treeview) {bbox cellselection cget children column configure delete detach drag drop exists focus heading identify index insert instate item move next parent prev see selection set state style tag xview yview}
set ::subCmd(_stdclass_oo) {create new destroy variable varname}
set ::subCmd(array) {anymore default donesearch exists for get names nextelement set size startsearch statistics unset}
set {::subCmd(array default)} {exists get set unset}
set ::subCmd(binary) {decode encode format scan}
set {::subCmd(binary decode)} {base64 hex uuencode}
set {::subCmd(binary encode)} {base64 hex uuencode}
set ::subCmd(chan) {blocked close configure copy create eof event flush gets names pending pipe pop postevent push puts read seek tell truncate}
set ::subCmd(clipboard) {append clear get}
set ::subCmd(clock) {add clicks format microseconds milliseconds scan seconds}
set ::subCmd(dict) {append create exists filter for get getdef getwithdefault incr info keys lappend map merge remove replace set size unset update values with}
set ::subCmd(encoding) {convertfrom convertto dirs names profiles system}
set ::subCmd(event) {add delete generate info}
set ::subCmd(file) {atime attributes channels copy delete dirname executable exists extension home isdirectory isfile join link lstat mkdir mtime nativename normalize owned pathtype readable readlink rename rootname separator size split stat system tail tempdir tempfile tildeexpand type volumes writable}
set ::subCmd(font) {actual configure create delete families measure metrics names}
set ::subCmd(history) {add change clear event info keep nextid redo}
set ::subCmd(image) {create delete height inuse names type types width}
set ::subCmd(info) {args body class cmdcount cmdtype commands complete coroutine default errorstack exists frame functions globals hostname level library loaded locals nameofexecutable object patchlevel procs script sharedlibextension tclversion vars}
set {::subCmd(info class)} {call constructor definition definitionnamespace destructor filters forward instances methods methodtype mixins properties subclasses superclasses variables}
set {::subCmd(info object)} {call class creationid definition filters forward isa methods methodtype mixins namespace properties variables vars}
set ::subCmd(interp) {alias aliases bgerror cancel children create debug delete eval exists expose hidden hide invokehidden issafe limit marktrusted recursionlimit share target transfer}
set ::subCmd(namespace) {children code current delete ensemble eval exists export forget import inscope origin parent path qualifiers tail unknown upvar which}
set ::subCmd(oo::class) {create destroy}
set ::subCmd(oo::object) {create destroy new}
set ::subCmd(option) {add clear get readfile}
set ::subCmd(package) {files forget ifneeded names prefer present provide require unknown vcompare versions vsatisfies}
set ::subCmd(selection) {clear get handle own}
set ::subCmd(self) {call caller class filter method namespace next object target}
set ::subCmd(string) {cat compare equal first index insert is last length map match range repeat replace reverse tolower totitle toupper trim trimleft trimright wordend wordstart}
set {::subCmd(string is)} {alnum alpha ascii boolean control dict digit double entier false graph integer list lower print punct space true unicode upper wideinteger wordchar xdigit}
set ::subCmd(tcl::prefix) {all longest match}
set ::subCmd(tcl::process) {autopurge list purge status}
set ::subCmd(tk) {appname busy caret fontchooser inactive print scaling sysnotify systray useinputmethods windowingsystem}
set ::subCmd(tkwait) {variable visibility window}
set ::subCmd(trace) {add info remove variable vdelete vinfo}
set {::subCmd(trace add)} {command execution variable}
set {::subCmd(trace add execution)} {enter enterstep leave leavestep}
set {::subCmd(trace info)} {command execution variable}
set {::subCmd(trace remove)} {command execution variable}
set ::subCmd(ttk::style) {configure element layout lookup map theme}
set {::subCmd(ttk::style element)} {create names options}
set {::subCmd(ttk::style theme)} {create names settings styles use}
set ::subCmd(update) idletasks
set ::subCmd(winfo) {atom atomname cells children class colormapfull containing depth exists fpixels geometry height id interps ismapped manager name parent pathname pixels pointerx pointerxy pointery reqheight reqwidth rgb rootx rooty screen screencells screendepth screenheight screenmmheight screenmmwidth screenvisual screenwidth server toplevel viewable visual visualid visualsavailable vrootheight vrootwidth vrootx vrooty width x y}
set ::subCmd(wm) {aspect attributes client colormapwindows command deiconify focusmodel forget frame geometry grid group iconbadge iconbitmap iconify iconmask iconname iconphoto iconposition iconwindow manage maxsize minsize overrideredirect positionfrom protocol resizable sizefrom stackorder state title transient withdraw}
set ::subCmd(zipfs) {canonical exists find info list lmkimg lmkzip mkimg mkkey mkzip mount mount_data root unmount}
set ::subCmd(zlib) {adler32 compress crc32 decompress deflate gunzip gzip inflate push stream}
set {::subCmd(zlib push)} {compress decompress deflate gunzip gzip inflate}
set {::subCmd(zlib stream)} {compress decompress deflate gunzip gzip inflate}

set {::option(. cget)} {-backgroundimage -bd -bgimg -borderwidth -class -menu -relief -screen -tile -use -background -bg -colormap -container -cursor -height -highlightbackground -highlightcolor -highlightthickness -padx -pady -takefocus -visual -width}
set {::option(. configure)} {-backgroundimage -bd -bgimg -borderwidth -class -menu -relief -screen -tile -use -background -bg -colormap -container -cursor -height -highlightbackground -highlightcolor -highlightthickness -padx -pady -takefocus -visual -width}
set {::option(_obj,button cget)} {-activebackground -activeforeground -anchor -background -bd -bg -bitmap -borderwidth -command -compound -cursor -default -disabledforeground -fg -font -foreground -height -highlightbackground -highlightcolor -highlightthickness -image -justify -overrelief -padx -pady -relief -repeatdelay -repeatinterval -state -takefocus -text -textvariable -underline -width -wraplength}
set {::option(_obj,button configure)} {-activebackground -activeforeground -anchor -background -bd -bg -bitmap -borderwidth -command -compound -cursor -default -disabledforeground -fg -font -foreground -height -highlightbackground -highlightcolor -highlightthickness -image -justify -overrelief -padx -pady -relief -repeatdelay -repeatinterval -state -takefocus -text -textvariable -underline -width -wraplength}
set {::option(_obj,button configure -textvariable)} n
set {::option(_obj,canvas cget)} {-background -bd -bg -borderwidth -closeenough -confine -cursor -height -highlightbackground -highlightcolor -highlightthickness -insertbackground -insertborderwidth -insertofftime -insertontime -insertwidth -offset -relief -scrollregion -selectbackground -selectborderwidth -selectforeground -state -takefocus -width -xscrollcommand -xscrollincrement -yscrollcommand -yscrollincrement}
set {::option(_obj,canvas configure)} {-background -bd -bg -borderwidth -closeenough -confine -cursor -height -highlightbackground -highlightcolor -highlightthickness -insertbackground -insertborderwidth -insertofftime -insertontime -insertwidth -offset -relief -scrollregion -selectbackground -selectborderwidth -selectforeground -state -takefocus -width -xscrollcommand -xscrollincrement -yscrollcommand -yscrollincrement}
set {::option(_obj,checkbutton cget)} {-activebackground -activeforeground -anchor -background -bd -bg -bitmap -borderwidth -command -compound -cursor -disabledforeground -fg -font -foreground -height -highlightbackground -highlightcolor -highlightthickness -image -indicatoron -justify -offrelief -offvalue -onvalue -overrelief -padx -pady -relief -selectcolor -selectimage -state -takefocus -text -textvariable -tristateimage -tristatevalue -underline -variable -width -wraplength}
set {::option(_obj,checkbutton configure)} {-activebackground -activeforeground -anchor -background -bd -bg -bitmap -borderwidth -command -compound -cursor -disabledforeground -fg -font -foreground -height -highlightbackground -highlightcolor -highlightthickness -image -indicatoron -justify -offrelief -offvalue -onvalue -overrelief -padx -pady -relief -selectcolor -selectimage -state -takefocus -text -textvariable -tristateimage -tristatevalue -underline -variable -width -wraplength}
set {::option(_obj,checkbutton configure -textvariable)} n
set {::option(_obj,checkbutton configure -variable)} n
set {::option(_obj,entry cget)} {-background -bd -bg -borderwidth -cursor -disabledbackground -disabledforeground -exportselection -fg -font -foreground -highlightbackground -highlightcolor -highlightthickness -insertbackground -insertborderwidth -insertofftime -insertontime -insertwidth -invalidcommand -invcmd -justify -placeholder -placeholderforeground -readonlybackground -relief -selectbackground -selectborderwidth -selectforeground -show -state -takefocus -textvariable -validate -validatecommand -vcmd -width -xscrollcommand}
set {::option(_obj,entry configure)} {-background -bd -bg -borderwidth -cursor -disabledbackground -disabledforeground -exportselection -fg -font -foreground -highlightbackground -highlightcolor -highlightthickness -insertbackground -insertborderwidth -insertofftime -insertontime -insertwidth -invalidcommand -invcmd -justify -placeholder -placeholderforeground -readonlybackground -relief -selectbackground -selectborderwidth -selectforeground -show -state -takefocus -textvariable -validate -validatecommand -vcmd -width -xscrollcommand}
set {::option(_obj,entry configure -textvariable)} n
set {::option(_obj,frame cget)} {-backgroundimage -bd -bgimg -borderwidth -class -relief -tile -background -bg -colormap -container -cursor -height -highlightbackground -highlightcolor -highlightthickness -padx -pady -takefocus -visual -width}
set {::option(_obj,frame configure)} {-backgroundimage -bd -bgimg -borderwidth -class -relief -tile -background -bg -colormap -container -cursor -height -highlightbackground -highlightcolor -highlightthickness -padx -pady -takefocus -visual -width}
set {::option(_obj,label cget)} {-activebackground -activeforeground -anchor -background -bd -bg -bitmap -borderwidth -compound -cursor -disabledforeground -fg -font -foreground -height -highlightbackground -highlightcolor -highlightthickness -image -justify -padx -pady -relief -state -takefocus -text -textvariable -underline -width -wraplength}
set {::option(_obj,label configure)} {-activebackground -activeforeground -anchor -background -bd -bg -bitmap -borderwidth -compound -cursor -disabledforeground -fg -font -foreground -height -highlightbackground -highlightcolor -highlightthickness -image -justify -padx -pady -relief -state -takefocus -text -textvariable -underline -width -wraplength}
set {::option(_obj,label configure -textvariable)} n
set {::option(_obj,labelframe cget)} {-bd -borderwidth -class -fg -font -foreground -labelanchor -labelwidget -relief -text -background -bg -colormap -container -cursor -height -highlightbackground -highlightcolor -highlightthickness -padx -pady -takefocus -visual -width}
set {::option(_obj,labelframe configure)} {-bd -borderwidth -class -fg -font -foreground -labelanchor -labelwidget -relief -text -background -bg -colormap -container -cursor -height -highlightbackground -highlightcolor -highlightthickness -padx -pady -takefocus -visual -width}
set {::option(_obj,listbox cget)} {-activestyle -background -bd -bg -borderwidth -cursor -disabledforeground -exportselection -fg -font -foreground -height -highlightbackground -highlightcolor -highlightthickness -justify -relief -selectbackground -selectborderwidth -selectforeground -selectmode -setgrid -state -takefocus -width -xscrollcommand -yscrollcommand -listvariable}
set {::option(_obj,listbox configure)} {-activestyle -background -bd -bg -borderwidth -cursor -disabledforeground -exportselection -fg -font -foreground -height -highlightbackground -highlightcolor -highlightthickness -justify -relief -selectbackground -selectborderwidth -selectforeground -selectmode -setgrid -state -takefocus -width -xscrollcommand -yscrollcommand -listvariable}
set {::option(_obj,listbox configure -listvariable)} n
set {::option(_obj,menu cget)} {-activebackground -activeborderwidth -activeforeground -activerelief -background -bd -bg -borderwidth -cursor -disabledforeground -fg -font -foreground -postcommand -relief -selectcolor -takefocus -tearoff -tearoffcommand -title -type}
set {::option(_obj,menu configure)} {-activebackground -activeborderwidth -activeforeground -activerelief -background -bd -bg -borderwidth -cursor -disabledforeground -fg -font -foreground -postcommand -relief -selectcolor -takefocus -tearoff -tearoffcommand -title -type}
set {::option(_obj,menubutton cget)} {-activebackground -activeforeground -anchor -background -bd -bg -bitmap -borderwidth -cursor -direction -disabledforeground -fg -font -foreground -height -highlightbackground -highlightcolor -highlightthickness -image -indicatoron -justify -menu -padx -pady -relief -compound -state -takefocus -text -textvariable -underline -width -wraplength}
set {::option(_obj,menubutton configure)} {-activebackground -activeforeground -anchor -background -bd -bg -bitmap -borderwidth -cursor -direction -disabledforeground -fg -font -foreground -height -highlightbackground -highlightcolor -highlightthickness -image -indicatoron -justify -menu -padx -pady -relief -compound -state -takefocus -text -textvariable -underline -width -wraplength}
set {::option(_obj,menubutton configure -textvariable)} n
set {::option(_obj,message cget)} {-anchor -aspect -background -bd -bg -borderwidth -cursor -fg -font -foreground -highlightbackground -highlightcolor -highlightthickness -justify -padx -pady -relief -takefocus -text -textvariable -width}
set {::option(_obj,message configure)} {-anchor -aspect -background -bd -bg -borderwidth -cursor -fg -font -foreground -highlightbackground -highlightcolor -highlightthickness -justify -padx -pady -relief -takefocus -text -textvariable -width}
set {::option(_obj,message configure -textvariable)} n
set {::option(_obj,panedwindow cget)} {-background -bd -bg -borderwidth -cursor -handlepad -handlesize -height -opaqueresize -orient -proxybackground -proxyborderwidth -proxyrelief -relief -sashcursor -sashpad -sashrelief -sashwidth -showhandle -width}
set {::option(_obj,panedwindow configure)} {-background -bd -bg -borderwidth -cursor -handlepad -handlesize -height -opaqueresize -orient -proxybackground -proxyborderwidth -proxyrelief -relief -sashcursor -sashpad -sashrelief -sashwidth -showhandle -width}
set {::option(_obj,radiobutton cget)} {-activebackground -activeforeground -anchor -background -bd -bg -bitmap -borderwidth -command -compound -cursor -disabledforeground -fg -font -foreground -height -highlightbackground -highlightcolor -highlightthickness -image -indicatoron -justify -offrelief -overrelief -padx -pady -relief -selectcolor -selectimage -state -takefocus -text -textvariable -tristateimage -tristatevalue -underline -value -variable -width -wraplength}
set {::option(_obj,radiobutton configure)} {-activebackground -activeforeground -anchor -background -bd -bg -bitmap -borderwidth -command -compound -cursor -disabledforeground -fg -font -foreground -height -highlightbackground -highlightcolor -highlightthickness -image -indicatoron -justify -offrelief -overrelief -padx -pady -relief -selectcolor -selectimage -state -takefocus -text -textvariable -tristateimage -tristatevalue -underline -value -variable -width -wraplength}
set {::option(_obj,radiobutton configure -textvariable)} n
set {::option(_obj,radiobutton configure -variable)} n
set {::option(_obj,scale cget)} {-activebackground -background -bigincrement -bd -bg -borderwidth -command -cursor -digits -fg -font -foreground -from -highlightbackground -highlightcolor -highlightthickness -label -length -orient -relief -repeatdelay -repeatinterval -resolution -showvalue -sliderlength -sliderrelief -state -takefocus -tickinterval -to -troughcolor -variable -width}
set {::option(_obj,scale configure)} {-activebackground -background -bigincrement -bd -bg -borderwidth -command -cursor -digits -fg -font -foreground -from -highlightbackground -highlightcolor -highlightthickness -label -length -orient -relief -repeatdelay -repeatinterval -resolution -showvalue -sliderlength -sliderrelief -state -takefocus -tickinterval -to -troughcolor -variable -width}
set {::option(_obj,scale configure -variable)} n
set {::option(_obj,scrollbar cget)} {-activebackground -activerelief -background -bd -bg -borderwidth -command -cursor -elementborderwidth -highlightbackground -highlightcolor -highlightthickness -jump -orient -relief -repeatdelay -repeatinterval -takefocus -troughcolor -width}
set {::option(_obj,scrollbar configure)} {-activebackground -activerelief -background -bd -bg -borderwidth -command -cursor -elementborderwidth -highlightbackground -highlightcolor -highlightthickness -jump -orient -relief -repeatdelay -repeatinterval -takefocus -troughcolor -width}
set {::option(_obj,spinbox cget)} {-activebackground -background -bd -bg -borderwidth -buttonbackground -buttoncursor -buttondownrelief -buttonuprelief -command -cursor -disabledbackground -disabledforeground -exportselection -fg -font -foreground -format -from -highlightbackground -highlightcolor -highlightthickness -increment -insertbackground -insertborderwidth -insertofftime -insertontime -insertwidth -invalidcommand -invcmd -justify -placeholder -placeholderforeground -relief -readonlybackground -repeatdelay -repeatinterval -selectbackground -selectborderwidth -selectforeground -state -takefocus -textvariable -to -validate -validatecommand -values -vcmd -width -wrap -xscrollcommand}
set {::option(_obj,spinbox configure)} {-activebackground -background -bd -bg -borderwidth -buttonbackground -buttoncursor -buttondownrelief -buttonuprelief -command -cursor -disabledbackground -disabledforeground -exportselection -fg -font -foreground -format -from -highlightbackground -highlightcolor -highlightthickness -increment -insertbackground -insertborderwidth -insertofftime -insertontime -insertwidth -invalidcommand -invcmd -justify -placeholder -placeholderforeground -relief -readonlybackground -repeatdelay -repeatinterval -selectbackground -selectborderwidth -selectforeground -state -takefocus -textvariable -to -validate -validatecommand -values -vcmd -width -wrap -xscrollcommand}
set {::option(_obj,spinbox configure -textvariable)} n
set {::option(_obj,text cget)} {-autoseparators -background -bd -bg -blockcursor -borderwidth -cursor -endline -exportselection -fg -font -foreground -height -highlightbackground -highlightcolor -highlightthickness -inactiveselectbackground -insertbackground -insertborderwidth -insertofftime -insertontime -insertunfocussed -insertwidth -maxundo -padx -pady -relief -selectbackground -selectborderwidth -selectforeground -setgrid -spacing1 -spacing2 -spacing3 -startline -state -tabs -tabstyle -takefocus -undo -width -wrap -xscrollcommand -yscrollcommand}
set {::option(_obj,text configure)} {-autoseparators -background -bd -bg -blockcursor -borderwidth -cursor -endline -exportselection -fg -font -foreground -height -highlightbackground -highlightcolor -highlightthickness -inactiveselectbackground -insertbackground -insertborderwidth -insertofftime -insertontime -insertunfocussed -insertwidth -maxundo -padx -pady -relief -selectbackground -selectborderwidth -selectforeground -setgrid -spacing1 -spacing2 -spacing3 -startline -state -tabs -tabstyle -takefocus -undo -width -wrap -xscrollcommand -yscrollcommand}
set {::option(_obj,text dump)} {-all -command -image -mark -tag -text -window}
set {::option(_obj,text dump -command)} x
set {::option(_obj,text search)} {-- -all -backwards -count -elide -exact -forwards -nocase -nolinestop -overlap -regexp -strictlimits}
set {::option(_obj,text search -count)} n
set {::option(_obj,tk::button cget)} {-activebackground -activeforeground -anchor -background -bd -bg -bitmap -borderwidth -command -compound -cursor -default -disabledforeground -fg -font -foreground -height -highlightbackground -highlightcolor -highlightthickness -image -justify -overrelief -padx -pady -relief -repeatdelay -repeatinterval -state -takefocus -text -textvariable -underline -width -wraplength}
set {::option(_obj,tk::button configure)} {-activebackground -activeforeground -anchor -background -bd -bg -bitmap -borderwidth -command -compound -cursor -default -disabledforeground -fg -font -foreground -height -highlightbackground -highlightcolor -highlightthickness -image -justify -overrelief -padx -pady -relief -repeatdelay -repeatinterval -state -takefocus -text -textvariable -underline -width -wraplength}
set {::option(_obj,tk::button configure -textvariable)} n
set {::option(_obj,tk::canvas cget)} {-background -bd -bg -borderwidth -closeenough -confine -cursor -height -highlightbackground -highlightcolor -highlightthickness -insertbackground -insertborderwidth -insertofftime -insertontime -insertwidth -offset -relief -scrollregion -selectbackground -selectborderwidth -selectforeground -state -takefocus -width -xscrollcommand -xscrollincrement -yscrollcommand -yscrollincrement}
set {::option(_obj,tk::canvas configure)} {-background -bd -bg -borderwidth -closeenough -confine -cursor -height -highlightbackground -highlightcolor -highlightthickness -insertbackground -insertborderwidth -insertofftime -insertontime -insertwidth -offset -relief -scrollregion -selectbackground -selectborderwidth -selectforeground -state -takefocus -width -xscrollcommand -xscrollincrement -yscrollcommand -yscrollincrement}
set {::option(_obj,tk::checkbutton cget)} {-activebackground -activeforeground -anchor -background -bd -bg -bitmap -borderwidth -command -compound -cursor -disabledforeground -fg -font -foreground -height -highlightbackground -highlightcolor -highlightthickness -image -indicatoron -justify -offrelief -offvalue -onvalue -overrelief -padx -pady -relief -selectcolor -selectimage -state -takefocus -text -textvariable -tristateimage -tristatevalue -underline -variable -width -wraplength}
set {::option(_obj,tk::checkbutton configure)} {-activebackground -activeforeground -anchor -background -bd -bg -bitmap -borderwidth -command -compound -cursor -disabledforeground -fg -font -foreground -height -highlightbackground -highlightcolor -highlightthickness -image -indicatoron -justify -offrelief -offvalue -onvalue -overrelief -padx -pady -relief -selectcolor -selectimage -state -takefocus -text -textvariable -tristateimage -tristatevalue -underline -variable -width -wraplength}
set {::option(_obj,tk::checkbutton configure -textvariable)} n
set {::option(_obj,tk::checkbutton configure -variable)} n
set {::option(_obj,tk::entry cget)} {-background -bd -bg -borderwidth -cursor -disabledbackground -disabledforeground -exportselection -fg -font -foreground -highlightbackground -highlightcolor -highlightthickness -insertbackground -insertborderwidth -insertofftime -insertontime -insertwidth -invalidcommand -invcmd -justify -placeholder -placeholderforeground -readonlybackground -relief -selectbackground -selectborderwidth -selectforeground -show -state -takefocus -textvariable -validate -validatecommand -vcmd -width -xscrollcommand}
set {::option(_obj,tk::entry configure)} {-background -bd -bg -borderwidth -cursor -disabledbackground -disabledforeground -exportselection -fg -font -foreground -highlightbackground -highlightcolor -highlightthickness -insertbackground -insertborderwidth -insertofftime -insertontime -insertwidth -invalidcommand -invcmd -justify -placeholder -placeholderforeground -readonlybackground -relief -selectbackground -selectborderwidth -selectforeground -show -state -takefocus -textvariable -validate -validatecommand -vcmd -width -xscrollcommand}
set {::option(_obj,tk::entry configure -textvariable)} n
set {::option(_obj,tk::frame cget)} {-backgroundimage -bd -bgimg -borderwidth -class -relief -tile -background -bg -colormap -container -cursor -height -highlightbackground -highlightcolor -highlightthickness -padx -pady -takefocus -visual -width}
set {::option(_obj,tk::frame configure)} {-backgroundimage -bd -bgimg -borderwidth -class -relief -tile -background -bg -colormap -container -cursor -height -highlightbackground -highlightcolor -highlightthickness -padx -pady -takefocus -visual -width}
set {::option(_obj,tk::label cget)} {-activebackground -activeforeground -anchor -background -bd -bg -bitmap -borderwidth -compound -cursor -disabledforeground -fg -font -foreground -height -highlightbackground -highlightcolor -highlightthickness -image -justify -padx -pady -relief -state -takefocus -text -textvariable -underline -width -wraplength}
set {::option(_obj,tk::label configure)} {-activebackground -activeforeground -anchor -background -bd -bg -bitmap -borderwidth -compound -cursor -disabledforeground -fg -font -foreground -height -highlightbackground -highlightcolor -highlightthickness -image -justify -padx -pady -relief -state -takefocus -text -textvariable -underline -width -wraplength}
set {::option(_obj,tk::label configure -textvariable)} n
set {::option(_obj,tk::labelframe cget)} {-bd -borderwidth -class -fg -font -foreground -labelanchor -labelwidget -relief -text -background -bg -colormap -container -cursor -height -highlightbackground -highlightcolor -highlightthickness -padx -pady -takefocus -visual -width}
set {::option(_obj,tk::labelframe configure)} {-bd -borderwidth -class -fg -font -foreground -labelanchor -labelwidget -relief -text -background -bg -colormap -container -cursor -height -highlightbackground -highlightcolor -highlightthickness -padx -pady -takefocus -visual -width}
set {::option(_obj,tk::listbox cget)} {-activestyle -background -bd -bg -borderwidth -cursor -disabledforeground -exportselection -fg -font -foreground -height -highlightbackground -highlightcolor -highlightthickness -justify -relief -selectbackground -selectborderwidth -selectforeground -selectmode -setgrid -state -takefocus -width -xscrollcommand -yscrollcommand -listvariable}
set {::option(_obj,tk::listbox configure)} {-activestyle -background -bd -bg -borderwidth -cursor -disabledforeground -exportselection -fg -font -foreground -height -highlightbackground -highlightcolor -highlightthickness -justify -relief -selectbackground -selectborderwidth -selectforeground -selectmode -setgrid -state -takefocus -width -xscrollcommand -yscrollcommand -listvariable}
set {::option(_obj,tk::listbox configure -listvariable)} n
set {::option(_obj,tk::menubutton cget)} {-activebackground -activeforeground -anchor -background -bd -bg -bitmap -borderwidth -cursor -direction -disabledforeground -fg -font -foreground -height -highlightbackground -highlightcolor -highlightthickness -image -indicatoron -justify -menu -padx -pady -relief -compound -state -takefocus -text -textvariable -underline -width -wraplength}
set {::option(_obj,tk::menubutton configure)} {-activebackground -activeforeground -anchor -background -bd -bg -bitmap -borderwidth -cursor -direction -disabledforeground -fg -font -foreground -height -highlightbackground -highlightcolor -highlightthickness -image -indicatoron -justify -menu -padx -pady -relief -compound -state -takefocus -text -textvariable -underline -width -wraplength}
set {::option(_obj,tk::menubutton configure -textvariable)} n
set {::option(_obj,tk::message cget)} {-anchor -aspect -background -bd -bg -borderwidth -cursor -fg -font -foreground -highlightbackground -highlightcolor -highlightthickness -justify -padx -pady -relief -takefocus -text -textvariable -width}
set {::option(_obj,tk::message configure)} {-anchor -aspect -background -bd -bg -borderwidth -cursor -fg -font -foreground -highlightbackground -highlightcolor -highlightthickness -justify -padx -pady -relief -takefocus -text -textvariable -width}
set {::option(_obj,tk::message configure -textvariable)} n
set {::option(_obj,tk::panedwindow cget)} {-background -bd -bg -borderwidth -cursor -handlepad -handlesize -height -opaqueresize -orient -proxybackground -proxyborderwidth -proxyrelief -relief -sashcursor -sashpad -sashrelief -sashwidth -showhandle -width}
set {::option(_obj,tk::panedwindow configure)} {-background -bd -bg -borderwidth -cursor -handlepad -handlesize -height -opaqueresize -orient -proxybackground -proxyborderwidth -proxyrelief -relief -sashcursor -sashpad -sashrelief -sashwidth -showhandle -width}
set {::option(_obj,tk::radiobutton cget)} {-activebackground -activeforeground -anchor -background -bd -bg -bitmap -borderwidth -command -compound -cursor -disabledforeground -fg -font -foreground -height -highlightbackground -highlightcolor -highlightthickness -image -indicatoron -justify -offrelief -overrelief -padx -pady -relief -selectcolor -selectimage -state -takefocus -text -textvariable -tristateimage -tristatevalue -underline -value -variable -width -wraplength}
set {::option(_obj,tk::radiobutton configure)} {-activebackground -activeforeground -anchor -background -bd -bg -bitmap -borderwidth -command -compound -cursor -disabledforeground -fg -font -foreground -height -highlightbackground -highlightcolor -highlightthickness -image -indicatoron -justify -offrelief -overrelief -padx -pady -relief -selectcolor -selectimage -state -takefocus -text -textvariable -tristateimage -tristatevalue -underline -value -variable -width -wraplength}
set {::option(_obj,tk::radiobutton configure -textvariable)} n
set {::option(_obj,tk::radiobutton configure -variable)} n
set {::option(_obj,tk::scale cget)} {-activebackground -background -bigincrement -bd -bg -borderwidth -command -cursor -digits -fg -font -foreground -from -highlightbackground -highlightcolor -highlightthickness -label -length -orient -relief -repeatdelay -repeatinterval -resolution -showvalue -sliderlength -sliderrelief -state -takefocus -tickinterval -to -troughcolor -variable -width}
set {::option(_obj,tk::scale configure)} {-activebackground -background -bigincrement -bd -bg -borderwidth -command -cursor -digits -fg -font -foreground -from -highlightbackground -highlightcolor -highlightthickness -label -length -orient -relief -repeatdelay -repeatinterval -resolution -showvalue -sliderlength -sliderrelief -state -takefocus -tickinterval -to -troughcolor -variable -width}
set {::option(_obj,tk::scale configure -variable)} n
set {::option(_obj,tk::scrollbar cget)} {-activebackground -activerelief -background -bd -bg -borderwidth -command -cursor -elementborderwidth -highlightbackground -highlightcolor -highlightthickness -jump -orient -relief -repeatdelay -repeatinterval -takefocus -troughcolor -width}
set {::option(_obj,tk::scrollbar configure)} {-activebackground -activerelief -background -bd -bg -borderwidth -command -cursor -elementborderwidth -highlightbackground -highlightcolor -highlightthickness -jump -orient -relief -repeatdelay -repeatinterval -takefocus -troughcolor -width}
set {::option(_obj,tk::spinbox cget)} {-activebackground -background -bd -bg -borderwidth -buttonbackground -buttoncursor -buttondownrelief -buttonuprelief -command -cursor -disabledbackground -disabledforeground -exportselection -fg -font -foreground -format -from -highlightbackground -highlightcolor -highlightthickness -increment -insertbackground -insertborderwidth -insertofftime -insertontime -insertwidth -invalidcommand -invcmd -justify -placeholder -placeholderforeground -relief -readonlybackground -repeatdelay -repeatinterval -selectbackground -selectborderwidth -selectforeground -state -takefocus -textvariable -to -validate -validatecommand -values -vcmd -width -wrap -xscrollcommand}
set {::option(_obj,tk::spinbox configure)} {-activebackground -background -bd -bg -borderwidth -buttonbackground -buttoncursor -buttondownrelief -buttonuprelief -command -cursor -disabledbackground -disabledforeground -exportselection -fg -font -foreground -format -from -highlightbackground -highlightcolor -highlightthickness -increment -insertbackground -insertborderwidth -insertofftime -insertontime -insertwidth -invalidcommand -invcmd -justify -placeholder -placeholderforeground -relief -readonlybackground -repeatdelay -repeatinterval -selectbackground -selectborderwidth -selectforeground -state -takefocus -textvariable -to -validate -validatecommand -values -vcmd -width -wrap -xscrollcommand}
set {::option(_obj,tk::spinbox configure -textvariable)} n
set {::option(_obj,tk::text cget)} {-autoseparators -background -bd -bg -blockcursor -borderwidth -cursor -endline -exportselection -fg -font -foreground -height -highlightbackground -highlightcolor -highlightthickness -inactiveselectbackground -insertbackground -insertborderwidth -insertofftime -insertontime -insertunfocussed -insertwidth -maxundo -padx -pady -relief -selectbackground -selectborderwidth -selectforeground -setgrid -spacing1 -spacing2 -spacing3 -startline -state -tabs -tabstyle -takefocus -undo -width -wrap -xscrollcommand -yscrollcommand}
set {::option(_obj,tk::text configure)} {-autoseparators -background -bd -bg -blockcursor -borderwidth -cursor -endline -exportselection -fg -font -foreground -height -highlightbackground -highlightcolor -highlightthickness -inactiveselectbackground -insertbackground -insertborderwidth -insertofftime -insertontime -insertunfocussed -insertwidth -maxundo -padx -pady -relief -selectbackground -selectborderwidth -selectforeground -setgrid -spacing1 -spacing2 -spacing3 -startline -state -tabs -tabstyle -takefocus -undo -width -wrap -xscrollcommand -yscrollcommand}
set {::option(_obj,tk::toplevel cget)} {-backgroundimage -bd -bgimg -borderwidth -class -menu -relief -screen -tile -use -background -bg -colormap -container -cursor -height -highlightbackground -highlightcolor -highlightthickness -padx -pady -takefocus -visual -width}
set {::option(_obj,tk::toplevel configure)} {-backgroundimage -bd -bgimg -borderwidth -class -menu -relief -screen -tile -use -background -bg -colormap -container -cursor -height -highlightbackground -highlightcolor -highlightthickness -padx -pady -takefocus -visual -width}
set {::option(_obj,toplevel cget)} {-backgroundimage -bd -bgimg -borderwidth -class -menu -relief -screen -tile -use -background -bg -colormap -container -cursor -height -highlightbackground -highlightcolor -highlightthickness -padx -pady -takefocus -visual -width}
set {::option(_obj,toplevel configure)} {-backgroundimage -bd -bgimg -borderwidth -class -menu -relief -screen -tile -use -background -bg -colormap -container -cursor -height -highlightbackground -highlightcolor -highlightthickness -padx -pady -takefocus -visual -width}
set {::option(_obj,ttk::button cget)} {-command -default -takefocus -justify -text -textvariable -underline -width -image -compound -padding -state -cursor -style -class}
set {::option(_obj,ttk::button configure)} {-command -default -takefocus -justify -text -textvariable -underline -width -image -compound -padding -state -cursor -style -class}
set {::option(_obj,ttk::button configure -textvariable)} n
set {::option(_obj,ttk::checkbutton cget)} {-variable -onvalue -offvalue -command -takefocus -justify -text -textvariable -underline -width -image -compound -padding -state -cursor -style -class}
set {::option(_obj,ttk::checkbutton configure)} {-variable -onvalue -offvalue -command -takefocus -justify -text -textvariable -underline -width -image -compound -padding -state -cursor -style -class}
set {::option(_obj,ttk::checkbutton configure -textvariable)} n
set {::option(_obj,ttk::checkbutton configure -variable)} n
set {::option(_obj,ttk::combobox cget)} {-height -postcommand -values -exportselection -font -invalidcommand -justify -placeholder -show -state -textvariable -validate -validatecommand -width -xscrollcommand -background -foreground -placeholderforeground -takefocus -cursor -style -class}
set {::option(_obj,ttk::combobox configure)} {-height -postcommand -values -exportselection -font -invalidcommand -justify -placeholder -show -state -textvariable -validate -validatecommand -width -xscrollcommand -background -foreground -placeholderforeground -takefocus -cursor -style -class}
set {::option(_obj,ttk::combobox configure -textvariable)} n
set {::option(_obj,ttk::entry cget)} {-exportselection -font -invalidcommand -justify -placeholder -show -state -textvariable -validate -validatecommand -width -xscrollcommand -background -foreground -placeholderforeground -takefocus -cursor -style -class}
set {::option(_obj,ttk::entry configure)} {-exportselection -font -invalidcommand -justify -placeholder -show -state -textvariable -validate -validatecommand -width -xscrollcommand -background -foreground -placeholderforeground -takefocus -cursor -style -class}
set {::option(_obj,ttk::entry configure -textvariable)} n
set {::option(_obj,ttk::frame cget)} {-borderwidth -padding -relief -width -height -takefocus -cursor -style -class}
set {::option(_obj,ttk::frame configure)} {-borderwidth -padding -relief -width -height -takefocus -cursor -style -class}
set {::option(_obj,ttk::label cget)} {-background -foreground -font -borderwidth -relief -anchor -justify -wraplength -takefocus -justify -text -textvariable -underline -width -image -compound -padding -state -cursor -style -class}
set {::option(_obj,ttk::label configure)} {-background -foreground -font -borderwidth -relief -anchor -justify -wraplength -takefocus -justify -text -textvariable -underline -width -image -compound -padding -state -cursor -style -class}
set {::option(_obj,ttk::label configure -textvariable)} n
set {::option(_obj,ttk::labelframe cget)} {-labelanchor -text -underline -labelwidget -borderwidth -padding -relief -width -height -takefocus -cursor -style -class}
set {::option(_obj,ttk::labelframe configure)} {-labelanchor -text -underline -labelwidget -borderwidth -padding -relief -width -height -takefocus -cursor -style -class}
set {::option(_obj,ttk::menubutton cget)} {-menu -direction -takefocus -justify -text -textvariable -underline -width -image -compound -padding -state -cursor -style -class}
set {::option(_obj,ttk::menubutton configure)} {-menu -direction -takefocus -justify -text -textvariable -underline -width -image -compound -padding -state -cursor -style -class}
set {::option(_obj,ttk::menubutton configure -textvariable)} n
set {::option(_obj,ttk::notebook cget)} {-width -height -padding -takefocus -cursor -style -class}
set {::option(_obj,ttk::notebook configure)} {-width -height -padding -takefocus -cursor -style -class}
set {::option(_obj,ttk::panedwindow cget)} {-orient -width -height -takefocus -cursor -style -class}
set {::option(_obj,ttk::panedwindow configure)} {-orient -width -height -takefocus -cursor -style -class}
set {::option(_obj,ttk::progressbar cget)} {-anchor -font -foreground -justify -length -maximum -mode -orient -phase -text -value -variable -wraplength -takefocus -cursor -style -class}
set {::option(_obj,ttk::progressbar configure)} {-anchor -font -foreground -justify -length -maximum -mode -orient -phase -text -value -variable -wraplength -takefocus -cursor -style -class}
set {::option(_obj,ttk::progressbar configure -variable)} n
set {::option(_obj,ttk::radiobutton cget)} {-variable -value -command -takefocus -justify -text -textvariable -underline -width -image -compound -padding -state -cursor -style -class}
set {::option(_obj,ttk::radiobutton configure)} {-variable -value -command -takefocus -justify -text -textvariable -underline -width -image -compound -padding -state -cursor -style -class}
set {::option(_obj,ttk::radiobutton configure -textvariable)} n
set {::option(_obj,ttk::radiobutton configure -variable)} n
set {::option(_obj,ttk::scale cget)} {-command -variable -orient -from -to -value -length -state -takefocus -cursor -style -class}
set {::option(_obj,ttk::scale configure)} {-command -variable -orient -from -to -value -length -state -takefocus -cursor -style -class}
set {::option(_obj,ttk::scale configure -variable)} n
set {::option(_obj,ttk::scrollbar cget)} {-command -orient -takefocus -cursor -style -class}
set {::option(_obj,ttk::scrollbar configure)} {-command -orient -takefocus -cursor -style -class}
set {::option(_obj,ttk::separator cget)} {-orient -takefocus -cursor -style -class}
set {::option(_obj,ttk::separator configure)} {-orient -takefocus -cursor -style -class}
set {::option(_obj,ttk::sizegrip cget)} {-takefocus -cursor -style -class}
set {::option(_obj,ttk::sizegrip configure)} {-takefocus -cursor -style -class}
set {::option(_obj,ttk::treeview cget)} {-columns -displaycolumns -show -selectmode -selecttype -height -padding -titlecolumns -titleitems -striped -xscrollcommand -yscrollcommand -takefocus -cursor -style -class}
set {::option(_obj,ttk::treeview configure)} {-columns -displaycolumns -show -selectmode -selecttype -height -padding -titlecolumns -titleitems -striped -xscrollcommand -yscrollcommand -takefocus -cursor -style -class}
set ::option(bell) {-displayof -nice}
set {::option(binary decode base64)} -strict
set {::option(binary decode hex)} -strict
set {::option(binary decode uuencode)} -strict
set {::option(binary encode base64)} {-maxlen -wrapchar}
set {::option(binary encode uuencode)} {-maxlen -wrapchar}
set ::option(button) {-activebackground -activeforeground -anchor -background -bd -bg -bitmap -borderwidth -command -compound -cursor -default -disabledforeground -fg -font -foreground -height -highlightbackground -highlightcolor -highlightthickness -image -justify -overrelief -padx -pady -relief -repeatdelay -repeatinterval -state -takefocus -text -textvariable -underline -width -wraplength}
set {::option(button -textvariable)} n
set ::option(canvas) {-background -bd -bg -borderwidth -closeenough -confine -cursor -height -highlightbackground -highlightcolor -highlightthickness -insertbackground -insertborderwidth -insertofftime -insertontime -insertwidth -offset -relief -scrollregion -selectbackground -selectborderwidth -selectforeground -state -takefocus -width -xscrollcommand -xscrollincrement -yscrollcommand -yscrollincrement}
set {::option(chan puts)} -nonewline
set ::option(checkbutton) {-activebackground -activeforeground -anchor -background -bd -bg -bitmap -borderwidth -command -compound -cursor -disabledforeground -fg -font -foreground -height -highlightbackground -highlightcolor -highlightthickness -image -indicatoron -justify -offrelief -offvalue -onvalue -overrelief -padx -pady -relief -selectcolor -selectimage -state -takefocus -text -textvariable -tristateimage -tristatevalue -underline -variable -width -wraplength}
set {::option(checkbutton -textvariable)} n
set {::option(checkbutton -variable)} n
set {::option(clock clicks)} {-microseconds -milliseconds}
set {::option(clock format)} {-format -gmt -locale -timezone}
set {::option(clock scan)} {-base -format -gmt -locale -timezone}
set ::option(entry) {-background -bd -bg -borderwidth -cursor -disabledbackground -disabledforeground -exportselection -fg -font -foreground -highlightbackground -highlightcolor -highlightthickness -insertbackground -insertborderwidth -insertofftime -insertontime -insertwidth -invalidcommand -invcmd -justify -placeholder -placeholderforeground -readonlybackground -relief -selectbackground -selectborderwidth -selectforeground -show -state -takefocus -textvariable -validate -validatecommand -vcmd -width -xscrollcommand}
set {::option(entry -textvariable)} n
set ::option(exec) {-- -ignorestderr -keepnewline}
set ::option(fconfigure) {-blocking -buffering -buffersize -closemode -encoding -eofchar -error -handshake -inputmode -lasterror -mode -peername -pollinterval -profile -queue -sockname -sysbuffer -timeout -translation -ttycontrol -ttystatus -winsize -xchar}
set ::option(fcopy) {-command -size}
set {::option(file attributes)} {-group -owner -permissions}
set {::option(file copy)} {-- -force}
set {::option(file delete)} {-- -force}
set {::option(file link)} {-hard -symbolic}
set {::option(file rename)} {-- -force}
set ::option(focus) {-displayof -force -lastfor}
set ::option(frame) {-backgroundimage -bd -bgimg -borderwidth -class -relief -tile -background -bg -colormap -container -cursor -height -highlightbackground -highlightcolor -highlightthickness -padx -pady -takefocus -visual -width}
set ::option(glob) {-- -directory -join -nocomplain -path -tails -types}
set {::option(glob -directory)} 1
set {::option(glob -path)} 1
set {::option(glob -types)} 1
set {::option(interp cancel)} {-- -unwind}
set {::option(interp invokehidden)} {-- -global -namespace}
set {::option(interp invokehidden -namespace)} 1
set ::option(label) {-activebackground -activeforeground -anchor -background -bd -bg -bitmap -borderwidth -compound -cursor -disabledforeground -fg -font -foreground -height -highlightbackground -highlightcolor -highlightthickness -image -justify -padx -pady -relief -state -takefocus -text -textvariable -underline -width -wraplength}
set {::option(label -textvariable)} n
set ::option(labelframe) {-bd -borderwidth -class -fg -font -foreground -labelanchor -labelwidget -relief -text -background -bg -colormap -container -cursor -height -highlightbackground -highlightcolor -highlightthickness -padx -pady -takefocus -visual -width}
set ::option(listbox) {-activestyle -background -bd -bg -borderwidth -cursor -disabledforeground -exportselection -fg -font -foreground -height -highlightbackground -highlightcolor -highlightthickness -justify -relief -selectbackground -selectborderwidth -selectforeground -selectmode -setgrid -state -takefocus -width -xscrollcommand -yscrollcommand -listvariable}
set {::option(listbox -listvariable)} n
set ::option(lsearch) {-all -ascii -bisect -decreasing -dictionary -exact -glob -increasing -index -inline -integer -nocase -not -real -regexp -sorted -start -stride -subindices}
set {::option(lsearch -index)} 1
set {::option(lsearch -start)} 1
set {::option(lsearch -stride)} 1
set ::option(lsort) {-ascii -command -decreasing -dictionary -increasing -index -indices -integer -nocase -real -stride -unique}
set {::option(lsort -command)} 1
set {::option(lsort -index)} 1
set {::option(lsort -stride)} 1
set ::option(menu) {-activebackground -activeborderwidth -activeforeground -activerelief -background -bd -bg -borderwidth -cursor -disabledforeground -fg -font -foreground -postcommand -relief -selectcolor -takefocus -tearoff -tearoffcommand -title -type}
set ::option(menubutton) {-activebackground -activeforeground -anchor -background -bd -bg -bitmap -borderwidth -cursor -direction -disabledforeground -fg -font -foreground -height -highlightbackground -highlightcolor -highlightthickness -image -indicatoron -justify -menu -padx -pady -relief -compound -state -takefocus -text -textvariable -underline -width -wraplength}
set {::option(menubutton -textvariable)} n
set ::option(message) {-anchor -aspect -background -bd -bg -borderwidth -cursor -fg -font -foreground -highlightbackground -highlightcolor -highlightthickness -justify -padx -pady -relief -takefocus -text -textvariable -width}
set {::option(message -textvariable)} n
set {::option(namespace which)} {-variable -command}
set {::option(namespace which -variable)} v
set {::option(oo::class create::filter)} {-append -clear -set}
set {::option(oo::class create::mixin)} {-append -clear -set}
set {::option(oo::class create::superclass)} {-append -clear -set}
set {::option(oo::class create::variable)} {-append -clear -set}
set ::option(oo::define::filter) {-append -appendifnew -clear -prepend -remove -set}
set ::option(oo::define::mixin) {-append -appendifnew -clear -prepend -remove -set}
set ::option(oo::define::superclass) {-append -appendifnew -clear -prepend -remove -set}
set ::option(oo::define::variable) {-append -appendifnew -clear -prepend -remove -set}
set ::option(oo::objdefine::filter) {-append -appendifnew -clear -prepend -remove -set}
set ::option(oo::objdefine::mixin) {-append -appendifnew -clear -prepend -remove -set}
set ::option(oo::objdefine::variable) {-append -appendifnew -clear -prepend -remove -set}
set {::option(package require)} -exact
set ::option(panedwindow) {-background -bd -bg -borderwidth -cursor -handlepad -handlesize -height -opaqueresize -orient -proxybackground -proxyborderwidth -proxyrelief -relief -sashcursor -sashpad -sashrelief -sashwidth -showhandle -width}
set ::option(puts) -nonewline
set ::option(radiobutton) {-activebackground -activeforeground -anchor -background -bd -bg -bitmap -borderwidth -command -compound -cursor -disabledforeground -fg -font -foreground -height -highlightbackground -highlightcolor -highlightthickness -image -indicatoron -justify -offrelief -overrelief -padx -pady -relief -selectcolor -selectimage -state -takefocus -text -textvariable -tristateimage -tristatevalue -underline -value -variable -width -wraplength}
set {::option(radiobutton -textvariable)} n
set {::option(radiobutton -variable)} n
set ::option(regexp) {-- -about -all -expanded -indices -inline -line -lineanchor -linestop -nocase -start}
set {::option(regexp -start)} 1
set ::option(regsub) {-- -all -command -expanded -line -lineanchor -linestop -nocase -start}
set {::option(regsub -command)} 1
set {::option(regsub -start)} 1
set ::option(scale) {-activebackground -background -bigincrement -bd -bg -borderwidth -command -cursor -digits -fg -font -foreground -from -highlightbackground -highlightcolor -highlightthickness -label -length -orient -relief -repeatdelay -repeatinterval -resolution -showvalue -sliderlength -sliderrelief -state -takefocus -tickinterval -to -troughcolor -variable -width}
set {::option(scale -variable)} n
set ::option(scrollbar) {-activebackground -activerelief -background -bd -bg -borderwidth -command -cursor -elementborderwidth -highlightbackground -highlightcolor -highlightthickness -jump -orient -relief -repeatdelay -repeatinterval -takefocus -troughcolor -width}
set ::option(send) {-- -async -displayof}
set {::option(send -displayof)} 1
set ::option(source) -encoding
set ::option(spinbox) {-activebackground -background -bd -bg -borderwidth -buttonbackground -buttoncursor -buttondownrelief -buttonuprelief -command -cursor -disabledbackground -disabledforeground -exportselection -fg -font -foreground -format -from -highlightbackground -highlightcolor -highlightthickness -increment -insertbackground -insertborderwidth -insertofftime -insertontime -insertwidth -invalidcommand -invcmd -justify -placeholder -placeholderforeground -relief -readonlybackground -repeatdelay -repeatinterval -selectbackground -selectborderwidth -selectforeground -state -takefocus -textvariable -to -validate -validatecommand -values -vcmd -width -wrap -xscrollcommand}
set {::option(spinbox -textvariable)} n
set {::option(string compare)} {-length -nocase}
set {::option(string compare -length)} 1
set {::option(string equal)} {-length -nocase}
set {::option(string equal -length)} 1
set {::option(string is)} {-failindex -strict}
set {::option(string is -failindex)} n
set {::option(string map)} -nocase
set {::option(string match)} -nocase
set ::option(subst) {-nobackslashes -nocommands -novariables}
set ::option(switch) {-- -exact -glob -indexvar -matchvar -nocase -regexp}
set {::option(switch -indexvar)} n
set {::option(switch -matchvar)} n
set {::option(tcl::prefix match)} {-error -exact -message}
set {::option(tcl::prefix match -error)} x
set {::option(tcl::prefix match -message)} x
set {::option(tcl::process status)} {-- -wait}
set ::option(text) {-autoseparators -background -bd -bg -blockcursor -borderwidth -cursor -endline -exportselection -fg -font -foreground -height -highlightbackground -highlightcolor -highlightthickness -inactiveselectbackground -insertbackground -insertborderwidth -insertofftime -insertontime -insertunfocussed -insertwidth -maxundo -padx -pady -relief -selectbackground -selectborderwidth -selectforeground -setgrid -spacing1 -spacing2 -spacing3 -startline -state -tabs -tabstyle -takefocus -undo -width -wrap -xscrollcommand -yscrollcommand}
set ::option(timerate) {-direct -calibrate -overhead}
set {::option(timerate -overhead)} 1
set ::option(tk::button) {-activebackground -activeforeground -anchor -background -bd -bg -bitmap -borderwidth -command -compound -cursor -default -disabledforeground -fg -font -foreground -height -highlightbackground -highlightcolor -highlightthickness -image -justify -overrelief -padx -pady -relief -repeatdelay -repeatinterval -state -takefocus -text -textvariable -underline -width -wraplength}
set {::option(tk::button -textvariable)} n
set ::option(tk::canvas) {-background -bd -bg -borderwidth -closeenough -confine -cursor -height -highlightbackground -highlightcolor -highlightthickness -insertbackground -insertborderwidth -insertofftime -insertontime -insertwidth -offset -relief -scrollregion -selectbackground -selectborderwidth -selectforeground -state -takefocus -width -xscrollcommand -xscrollincrement -yscrollcommand -yscrollincrement}
set ::option(tk::checkbutton) {-activebackground -activeforeground -anchor -background -bd -bg -bitmap -borderwidth -command -compound -cursor -disabledforeground -fg -font -foreground -height -highlightbackground -highlightcolor -highlightthickness -image -indicatoron -justify -offrelief -offvalue -onvalue -overrelief -padx -pady -relief -selectcolor -selectimage -state -takefocus -text -textvariable -tristateimage -tristatevalue -underline -variable -width -wraplength}
set {::option(tk::checkbutton -textvariable)} n
set {::option(tk::checkbutton -variable)} n
set ::option(tk::entry) {-background -bd -bg -borderwidth -cursor -disabledbackground -disabledforeground -exportselection -fg -font -foreground -highlightbackground -highlightcolor -highlightthickness -insertbackground -insertborderwidth -insertofftime -insertontime -insertwidth -invalidcommand -invcmd -justify -placeholder -placeholderforeground -readonlybackground -relief -selectbackground -selectborderwidth -selectforeground -show -state -takefocus -textvariable -validate -validatecommand -vcmd -width -xscrollcommand}
set {::option(tk::entry -textvariable)} n
set ::option(tk::frame) {-backgroundimage -bd -bgimg -borderwidth -class -relief -tile -background -bg -colormap -container -cursor -height -highlightbackground -highlightcolor -highlightthickness -padx -pady -takefocus -visual -width}
set ::option(tk::label) {-activebackground -activeforeground -anchor -background -bd -bg -bitmap -borderwidth -compound -cursor -disabledforeground -fg -font -foreground -height -highlightbackground -highlightcolor -highlightthickness -image -justify -padx -pady -relief -state -takefocus -text -textvariable -underline -width -wraplength}
set {::option(tk::label -textvariable)} n
set ::option(tk::labelframe) {-bd -borderwidth -class -fg -font -foreground -labelanchor -labelwidget -relief -text -background -bg -colormap -container -cursor -height -highlightbackground -highlightcolor -highlightthickness -padx -pady -takefocus -visual -width}
set ::option(tk::listbox) {-activestyle -background -bd -bg -borderwidth -cursor -disabledforeground -exportselection -fg -font -foreground -height -highlightbackground -highlightcolor -highlightthickness -justify -relief -selectbackground -selectborderwidth -selectforeground -selectmode -setgrid -state -takefocus -width -xscrollcommand -yscrollcommand -listvariable}
set {::option(tk::listbox -listvariable)} n
set ::option(tk::menubutton) {-activebackground -activeforeground -anchor -background -bd -bg -bitmap -borderwidth -cursor -direction -disabledforeground -fg -font -foreground -height -highlightbackground -highlightcolor -highlightthickness -image -indicatoron -justify -menu -padx -pady -relief -compound -state -takefocus -text -textvariable -underline -width -wraplength}
set {::option(tk::menubutton -textvariable)} n
set ::option(tk::message) {-anchor -aspect -background -bd -bg -borderwidth -cursor -fg -font -foreground -highlightbackground -highlightcolor -highlightthickness -justify -padx -pady -relief -takefocus -text -textvariable -width}
set {::option(tk::message -textvariable)} n
set ::option(tk::panedwindow) {-background -bd -bg -borderwidth -cursor -handlepad -handlesize -height -opaqueresize -orient -proxybackground -proxyborderwidth -proxyrelief -relief -sashcursor -sashpad -sashrelief -sashwidth -showhandle -width}
set ::option(tk::radiobutton) {-activebackground -activeforeground -anchor -background -bd -bg -bitmap -borderwidth -command -compound -cursor -disabledforeground -fg -font -foreground -height -highlightbackground -highlightcolor -highlightthickness -image -indicatoron -justify -offrelief -overrelief -padx -pady -relief -selectcolor -selectimage -state -takefocus -text -textvariable -tristateimage -tristatevalue -underline -value -variable -width -wraplength}
set {::option(tk::radiobutton -textvariable)} n
set {::option(tk::radiobutton -variable)} n
set ::option(tk::scale) {-activebackground -background -bigincrement -bd -bg -borderwidth -command -cursor -digits -fg -font -foreground -from -highlightbackground -highlightcolor -highlightthickness -label -length -orient -relief -repeatdelay -repeatinterval -resolution -showvalue -sliderlength -sliderrelief -state -takefocus -tickinterval -to -troughcolor -variable -width}
set {::option(tk::scale -variable)} n
set ::option(tk::scrollbar) {-activebackground -activerelief -background -bd -bg -borderwidth -command -cursor -elementborderwidth -highlightbackground -highlightcolor -highlightthickness -jump -orient -relief -repeatdelay -repeatinterval -takefocus -troughcolor -width}
set ::option(tk::spinbox) {-activebackground -background -bd -bg -borderwidth -buttonbackground -buttoncursor -buttondownrelief -buttonuprelief -command -cursor -disabledbackground -disabledforeground -exportselection -fg -font -foreground -format -from -highlightbackground -highlightcolor -highlightthickness -increment -insertbackground -insertborderwidth -insertofftime -insertontime -insertwidth -invalidcommand -invcmd -justify -placeholder -placeholderforeground -relief -readonlybackground -repeatdelay -repeatinterval -selectbackground -selectborderwidth -selectforeground -state -takefocus -textvariable -to -validate -validatecommand -values -vcmd -width -wrap -xscrollcommand}
set {::option(tk::spinbox -textvariable)} n
set ::option(tk::text) {-autoseparators -background -bd -bg -blockcursor -borderwidth -cursor -endline -exportselection -fg -font -foreground -height -highlightbackground -highlightcolor -highlightthickness -inactiveselectbackground -insertbackground -insertborderwidth -insertofftime -insertontime -insertunfocussed -insertwidth -maxundo -padx -pady -relief -selectbackground -selectborderwidth -selectforeground -setgrid -spacing1 -spacing2 -spacing3 -startline -state -tabs -tabstyle -takefocus -undo -width -wrap -xscrollcommand -yscrollcommand}
set ::option(tk::toplevel) {-backgroundimage -bd -bgimg -borderwidth -class -menu -relief -screen -tile -use -background -bg -colormap -container -cursor -height -highlightbackground -highlightcolor -highlightthickness -padx -pady -takefocus -visual -width}
set ::option(tk_chooseColor) {-initialcolor -parent -title}
set ::option(tk_chooseDirectory) {-initialdir -mustexist -parent -title}
set ::option(tk_getOpenFile) {-defaultextension -filetypes -initialdir -initialfile -multiple -parent -title -typevariable}
set ::option(tk_getSaveFile) {-confirmoverwrite -defaultextension -filetypes -initialdir -initialfile -parent -title -typevariable}
set ::option(tk_messageBox) {-default -detail -icon -message -parent -title -type}
set ::option(toplevel) {-backgroundimage -bd -bgimg -borderwidth -class -menu -relief -screen -tile -use -background -bg -colormap -container -cursor -height -highlightbackground -highlightcolor -highlightthickness -padx -pady -takefocus -visual -width}
set ::option(ttk::button) {-command -default -takefocus -justify -text -textvariable -underline -width -image -compound -padding -state -cursor -style -class}
set {::option(ttk::button -textvariable)} n
set ::option(ttk::checkbutton) {-variable -onvalue -offvalue -command -takefocus -justify -text -textvariable -underline -width -image -compound -padding -state -cursor -style -class}
set {::option(ttk::checkbutton -textvariable)} n
set {::option(ttk::checkbutton -variable)} n
set ::option(ttk::combobox) {-height -postcommand -values -exportselection -font -invalidcommand -justify -placeholder -show -state -textvariable -validate -validatecommand -width -xscrollcommand -background -foreground -placeholderforeground -takefocus -cursor -style -class}
set {::option(ttk::combobox -textvariable)} n
set ::option(ttk::entry) {-exportselection -font -invalidcommand -justify -placeholder -show -state -textvariable -validate -validatecommand -width -xscrollcommand -background -foreground -placeholderforeground -takefocus -cursor -style -class}
set {::option(ttk::entry -textvariable)} n
set ::option(ttk::frame) {-borderwidth -padding -relief -width -height -takefocus -cursor -style -class}
set ::option(ttk::label) {-background -foreground -font -borderwidth -relief -anchor -justify -wraplength -takefocus -justify -text -textvariable -underline -width -image -compound -padding -state -cursor -style -class}
set {::option(ttk::label -textvariable)} n
set ::option(ttk::labelframe) {-labelanchor -text -underline -labelwidget -borderwidth -padding -relief -width -height -takefocus -cursor -style -class}
set ::option(ttk::menubutton) {-menu -direction -takefocus -justify -text -textvariable -underline -width -image -compound -padding -state -cursor -style -class}
set {::option(ttk::menubutton -textvariable)} n
set ::option(ttk::notebook) {-width -height -padding -takefocus -cursor -style -class}
set ::option(ttk::panedwindow) {-orient -width -height -takefocus -cursor -style -class}
set ::option(ttk::progressbar) {-anchor -font -foreground -justify -length -maximum -mode -orient -phase -text -value -variable -wraplength -takefocus -cursor -style -class}
set {::option(ttk::progressbar -variable)} n
set ::option(ttk::radiobutton) {-variable -value -command -takefocus -justify -text -textvariable -underline -width -image -compound -padding -state -cursor -style -class}
set {::option(ttk::radiobutton -textvariable)} n
set {::option(ttk::radiobutton -variable)} n
set ::option(ttk::scale) {-command -variable -orient -from -to -value -length -state -takefocus -cursor -style -class}
set {::option(ttk::scale -variable)} n
set ::option(ttk::scrollbar) {-command -orient -takefocus -cursor -style -class}
set ::option(ttk::separator) {-orient -takefocus -cursor -style -class}
set ::option(ttk::sizegrip) {-takefocus -cursor -style -class}
set {::option(ttk::style theme create)} {-parent -settings}
set ::option(ttk::treeview) {-columns -displaycolumns -show -selectmode -selecttype -height -padding -titlecolumns -titleitems -striped -xscrollcommand -yscrollcommand -takefocus -cursor -style -class}
set ::option(unload) {-- -keeplibrary -nocomplain}
set ::option(unset) {-nocomplain --}
set {::option(zipfs list)} {-glob -regexp}
set {::option(zlib gunzip)} {-buffersize -headerVar}
set {::option(zlib gzip)} {-header -level}
set {::option(zlib push)} {-dictionary -header -level}
set {::option(zlib stream compress)} {-dictionary -level}
set {::option(zlib stream decompress)} -dictionary
set {::option(zlib stream deflate)} {-dictionary -level}
set {::option(zlib stream gzip)} {-header -level}
set {::option(zlib stream inflate)} -dictionary

